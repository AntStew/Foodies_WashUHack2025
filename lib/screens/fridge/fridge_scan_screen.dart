import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/auth_service.dart';
import '../../services/storage_service.dart';
import '../../services/openai_service.dart';
import '../../services/firestore_service.dart';
import '../../models/fridge_item_model.dart';
import '../../models/shopping_list_item_model.dart';

class FridgeScanScreen extends StatefulWidget {
  const FridgeScanScreen({super.key});

  @override
  State<FridgeScanScreen> createState() => _FridgeScanScreenState();
}

class _FridgeScanScreenState extends State<FridgeScanScreen> {
  final _authService = AuthService();
  final _storageService = StorageService();
  final _openAiService = OpenAIService();
  final _firestoreService = FirestoreService();
  final _picker = ImagePicker();

  File? _imageFile;
  XFile? _pickedFile;
  bool _isProcessing = false;
  String _statusMessage = '';

  Future<void> _generateShoppingList(user, List<Map<String, String>> fridgeItems) async {
    try {
      // Get user profile for preferences
      final userProfile = await _firestoreService.getUserProfile(user.uid);

      final dietaryRestrictions = userProfile?.dietaryRestrictions ?? [];
      final cuisinePreferences = userProfile?.cuisinePreferences ?? [];
      final servingSize = userProfile?.servingSize ?? 2;

      // Get current ingredient names
      final currentIngredients = fridgeItems.map((item) => item['name']!).toList();

      // Generate shopping list with AI
      final aiResponse = await _openAiService.generateShoppingList(
        currentIngredients,
        dietaryRestrictions,
        cuisinePreferences,
        servingSize,
      );

      final shoppingListItems = aiResponse['items'] as List;

      if (shoppingListItems.isNotEmpty) {
        // Convert to ShoppingListItem models
        final now = DateTime.now();
        final items = shoppingListItems.map((itemData) {
          final item = itemData as Map<String, dynamic>;
          return ShoppingListItem(
            id: '',
            name: item['name'] as String? ?? '',
            category: item['category'] as String? ?? 'Other',
            quantity: item['quantity'] as String? ?? '1',
            isChecked: false,
            createdAt: now,
          );
        }).toList();

        // Save to Firestore
        await _firestoreService.addMultipleShoppingListItems(user.uid, items);
      }
    } catch (e) {
      // Silent fail for shopping list generation - don't block the main flow
      debugPrint('Error generating shopping list: $e');
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);

      if (pickedFile != null) {
        setState(() {
          _pickedFile = pickedFile;
          if (!kIsWeb) {
            _imageFile = File(pickedFile.path);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  Future<void> _scanFridge() async {
    if (_pickedFile == null && _imageFile == null) return;

    final user = _authService.currentUser;
    if (user == null) return;

    setState(() {
      _isProcessing = true;
      _statusMessage = 'Uploading image...';
    });

    try {
      // Upload image to Firebase Storage
      String imageUrl;
      if (kIsWeb) {
        imageUrl = await _storageService.uploadFridgeImageWeb(user.uid, _pickedFile!);
      } else {
        imageUrl = await _storageService.uploadFridgeImage(user.uid, _imageFile!);
      }

      setState(() {
        _statusMessage = 'Analyzing fridge contents...';
      });

      // Analyze with OpenAI Vision
      final items = await _openAiService.analyzeFridgeImage(imageUrl);

      if (items.isEmpty) {
        throw Exception('No items detected in the image');
      }

      setState(() {
        _statusMessage = 'Saving ${items.length} items...';
      });

      // Save items to Firestore
      final now = DateTime.now();
      for (var itemData in items) {
        final item = FridgeItem(
          id: '',
          name: itemData['name']!,
          category: itemData['category']!,
          quantity: itemData['quantity']!,
          freshness: itemData['freshness']!,
          addedDate: now,
          lastScanned: now,
          imageUrl: imageUrl,
        );

        await _firestoreService.addFridgeItem(user.uid, item);
      }

      // Generate shopping list
      setState(() {
        _statusMessage = 'Generating shopping list...';
      });

      await _generateShoppingList(user, items);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Successfully added ${items.length} items and generated shopping list!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _statusMessage = '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Fridge'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.7),
                Colors.transparent,
              ],
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      extendBodyBehindAppBar: true,
      body: _isProcessing
          ? Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.white, Colors.grey],
                ),
              ),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _statusMessage,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : Stack(
              children: [
                // Background Image or Gradient
                if (_pickedFile != null)
                  Positioned.fill(
                    child: kIsWeb
                        ? Image.network(
                            _pickedFile!.path,
                            fit: BoxFit.cover,
                          )
                        : _imageFile != null
                            ? Image.file(
                                _imageFile!,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [Colors.white, Colors.grey],
                                  ),
                                ),
                              ),
                  )
                else
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.white, Colors.grey],
                      ),
                    ),
                  ),

                // Content - Centered with black translucent background
                Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Title
                          Text(
                            _pickedFile != null ? 'Ready to Analyze?' : 'Scan Your Fridge',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _pickedFile != null 
                                ? 'Tap analyze to identify your ingredients'
                                : 'Take a photo or choose from gallery',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 18,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 40),

                          // Action buttons - Centered and responsive
                          if (_pickedFile != null) ...[
                            // Analyze button
                            Container(
                              width: 280,
                              height: 70,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Colors.green, Colors.greenAccent],
                                ),
                                borderRadius: BorderRadius.circular(35),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.green.withValues(alpha: 0.4),
                                    blurRadius: 25,
                                    offset: const Offset(0, 15),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: _scanFridge,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(35),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.auto_awesome, color: Colors.white, size: 28),
                                    SizedBox(width: 12),
                                    Text(
                                      'Analyze Fridge',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            
                            // Change image button
                            Container(
                              width: 200,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                              ),
                              child: ElevatedButton(
                                onPressed: () => _pickImage(ImageSource.gallery),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.swap_horiz, color: Colors.white, size: 20),
                                    SizedBox(width: 8),
                                    Text(
                                      'Change Image',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ] else ...[
                            // Upload buttons - Centered and responsive
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 400),
                              child: Column(
                                children: [
                                  // Camera button (always show)
                                  Container(
                                    width: double.infinity,
                                    height: 70,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Colors.orange, Colors.deepOrange],
                                      ),
                                      borderRadius: BorderRadius.circular(35),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.orange.withValues(alpha: 0.4),
                                          blurRadius: 25,
                                          offset: const Offset(0, 15),
                                        ),
                                      ],
                                    ),
                                    child: ElevatedButton(
                                      onPressed: () => _pickImage(ImageSource.camera),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(35),
                                        ),
                                      ),
                                      child: const Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.camera_alt, color: Colors.white, size: 28),
                                          SizedBox(width: 12),
                                          Text(
                                            'Take Photo',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  
                                  // Gallery button
                                  Container(
                                    width: double.infinity,
                                    height: 70,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Colors.blue, Colors.blueAccent],
                                      ),
                                      borderRadius: BorderRadius.circular(35),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.blue.withValues(alpha: 0.4),
                                          blurRadius: 25,
                                          offset: const Offset(0, 15),
                                        ),
                                      ],
                                    ),
                                    child: ElevatedButton(
                                      onPressed: () => _pickImage(ImageSource.gallery),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(35),
                                        ),
                                      ),
                                      child: const Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.photo_library, color: Colors.white, size: 28),
                                          SizedBox(width: 12),
                                          Text(
                                            'Choose from Gallery',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
