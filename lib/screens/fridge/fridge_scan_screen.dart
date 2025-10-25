import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/auth_service.dart';
import '../../services/storage_service.dart';
import '../../services/openai_service.dart';
import '../../services/firestore_service.dart';
import '../../models/fridge_item_model.dart';

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

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Successfully added ${items.length} items!')),
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
      appBar: AppBar(title: const Text('Scan Fridge')),
      body: _isProcessing
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(_statusMessage),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_pickedFile != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: kIsWeb
                          ? Image.network(
                              _pickedFile!.path,
                              height: 300,
                              fit: BoxFit.cover,
                            )
                          : _imageFile != null
                              ? Image.file(
                                  _imageFile!,
                                  height: 300,
                                  fit: BoxFit.cover,
                                )
                              : const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 16),
                  ] else ...[
                    Container(
                      height: 300,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt, size: 64, color: Colors.grey),
                            SizedBox(height: 8),
                            Text(
                              'No image selected',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (!kIsWeb) ...[
                    ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Take Photo'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: Text(kIsWeb ? 'Choose Image' : 'Choose from Gallery'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_pickedFile != null)
                    ElevatedButton(
                      onPressed: _scanFridge,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text(
                        'Analyze Fridge',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
