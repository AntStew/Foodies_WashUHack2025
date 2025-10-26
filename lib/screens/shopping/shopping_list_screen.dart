import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:async';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../services/openai_service.dart';
import '../../models/shopping_list_item_model.dart';
import 'widgets/category_section_widget.dart';
import 'widgets/store_suggestions_widget.dart';
import 'widgets/empty_state_widget.dart';
import 'widgets/add_item_dialog.dart';

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  final _authService = AuthService();
  final _firestoreService = FirestoreService();
  final _openAIService = OpenAIService();
  bool _isGenerating = false;
  List<Map<String, dynamic>> _suggestedStores = [];
  bool _hasTimedOut = false;
  Timer? _timeoutTimer;

  @override
  void initState() {
    super.initState();
    _loadSuggestedStores();
    
    // Set up timeout timer
    _timeoutTimer = Timer(const Duration(seconds: 20), () {
      if (mounted) {
        setState(() {
          _hasTimedOut = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    super.dispose();
  }

  void _loadSuggestedStores() async {
    final user = _authService.currentUser;
    if (user == null) return;

    try {
      // Get stores once with timeout to prevent freezing
      final storesSnapshot = await _firestoreService
          .getSuggestedStores(user.uid)
          .first
          .timeout(const Duration(seconds: 5));

      if (!mounted) return;
      setState(() {
        _suggestedStores = storesSnapshot.map((store) => {
          'name': store.name,
          'reason': store.reason,
          'categories': store.categories,
        }).toList();
      });
    } catch (e) {
      // Don't crash if stores can't load, just show empty
      // Error is silently ignored as suggested stores are optional
      if (!mounted) return;
      setState(() {
        _suggestedStores = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 800;

     return Scaffold(
       body: Container(
         decoration: const BoxDecoration(
           image: DecorationImage(
             image: AssetImage('design/background/aisle.jpg'),
             fit: BoxFit.cover,
             opacity: 0.6,
           ),
         ),
         child: Scaffold(
           backgroundColor: Colors.transparent,
           extendBodyBehindAppBar: true,
           appBar: PreferredSize(
             preferredSize: const Size.fromHeight(kToolbarHeight),
             child: ClipRect(
               child: BackdropFilter(
                 filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                 child: AppBar(
                   leading: IconButton(
                     icon: const Icon(Icons.arrow_back, color: Colors.black),
                     onPressed: () {
                       Navigator.pushReplacementNamed(context, '/home');
                     },
                   ),
                   automaticallyImplyLeading: false,
                   title: Text(
                     'Shopping List',
                     style: TextStyle(
                       fontWeight: FontWeight.bold,
                       color: Colors.black,
                       fontSize: 20,
                       shadows: [
                         // Main shadow for depth
                         Shadow(
                           offset: const Offset(1, 1),
                           blurRadius: 2,
                           color: Colors.black.withValues(alpha: 0.3),
                         ),
                         // Highlight shadow for 3D effect
                         Shadow(
                           offset: const Offset(-0.5, -0.5),
                           blurRadius: 1,
                           color: Colors.white.withValues(alpha: 0.4),
                         ),
                       ],
                     ),
                   ),
                   backgroundColor: Colors.white.withValues(alpha: 0.15),
                   elevation: 0,
                   iconTheme: const IconThemeData(color: Colors.black),
                   actions: [
                     IconButton(
                       icon: const Icon(Icons.add_circle_outline, color: Colors.black),
                       tooltip: 'Add item',
                       onPressed: () {
                         if (user != null) {
                           showDialog(
                             context: context,
                             builder: (context) => AddItemDialog(userId: user.uid),
                           );
                         }
                       },
                     ),
                     IconButton(
                       icon: const Icon(Icons.delete_sweep, color: Colors.black54),
                       tooltip: 'Clear checked items',
                       onPressed: () => _showClearCheckedDialog(context),
                     ),
                     IconButton(
                       icon: const Icon(Icons.delete_forever, color: Colors.red),
                       tooltip: 'Remove all items',
                       onPressed: () => _showRemoveAllDialog(context),
                     ),
                   ],
                 ),
               ),
             ),
           ),
           body: Padding(
             padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + kToolbarHeight),
             child: user == null
                 ? const Center(
                     child: Text(
                       'Not logged in',
                       style: TextStyle(fontSize: 16, color: Color(0xFF718096)),
                     ),
                   )
                 : StreamBuilder<List<ShoppingListItem>>(
                     stream: _firestoreService.getShoppingList(user.uid).timeout(
                       const Duration(seconds: 15),
                       onTimeout: (eventSink) {
                         eventSink.addError('Shopping list loading timed out');
                         eventSink.close();
                       },
                     ),
                     builder: (context, snapshot) {
                       // Check for timeout first
                       if (_hasTimedOut) {
                         return Center(
                           child: Column(
                             mainAxisAlignment: MainAxisAlignment.center,
                             children: [
                               Icon(
                                 Icons.timer_off,
                                 size: 64,
                                 color: Colors.orange[300],
                               ),
                               const SizedBox(height: 16),
                               const Text(
                                 'Loading timed out',
                                 style: TextStyle(
                                   color: Color(0xFF718096),
                                   fontSize: 18,
                                   fontWeight: FontWeight.w600,
                                 ),
                               ),
                               const SizedBox(height: 8),
                               const Text(
                                 'Please check your connection and try again',
                                 style: TextStyle(
                                   color: Color(0xFF718096),
                                   fontSize: 14,
                                 ),
                               ),
                               const SizedBox(height: 16),
                               ElevatedButton(
                                 onPressed: () {
                                   setState(() {
                                     _hasTimedOut = false;
                                   });
                                   _timeoutTimer = Timer(const Duration(seconds: 20), () {
                                     if (mounted) {
                                       setState(() {
                                         _hasTimedOut = true;
                                       });
                                     }
                                   });
                                 },
                                 child: const Text('Retry'),
                               ),
                             ],
                           ),
                         );
                       }

                       if (snapshot.connectionState == ConnectionState.waiting) {
                         return const Center(
                           child: CircularProgressIndicator(
                             valueColor: AlwaysStoppedAnimation<Color>(
                               Color(0xFF667eea),
                             ),
                           ),
                         );
                       }

                       if (snapshot.hasError) {
                         return Center(
                           child: Column(
                             mainAxisAlignment: MainAxisAlignment.center,
                             children: [
                               Icon(
                                 Icons.error_outline,
                                 size: 64,
                                 color: Colors.red[300],
                               ),
                               const SizedBox(height: 16),
                               Text(
                                 'Error: ${snapshot.error}',
                                 style: const TextStyle(
                                   color: Color(0xFF718096),
                                   fontSize: 16,
                                 ),
                               ),
                             ],
                           ),
                         );
                       }

                       final items = snapshot.data ?? [];

                       // Cancel timeout timer since we received data
                       _timeoutTimer?.cancel();

                       if (items.isEmpty) {
                         return const EmptyStateWidget();
                       }

                       // Group items by category
                       final groupedItems = <String, List<ShoppingListItem>>{};
                       for (final item in items) {
                         groupedItems.putIfAbsent(item.category, () => []).add(item);
                       }

                       final sortedCategories = groupedItems.keys.toList()..sort();

                       if (isDesktop) {
                         return _buildDesktopLayout(sortedCategories, groupedItems, user.uid);
                       } else {
                         return _buildMobileLayout(sortedCategories, groupedItems, user.uid);
                       }
                     },
                   ),
           ),
         ),
       ),
       floatingActionButton: _isGenerating
           ? null
           : Padding(
               padding: EdgeInsets.only(
                 bottom: isDesktop ? 16 : 0,
                 right: isDesktop ? 16 : 0,
               ),
               child: FloatingActionButton.extended(
                 onPressed: () => _generateShoppingList(context),
                 backgroundColor: const Color(0xFF667eea),
                 elevation: 8,
                 icon: const Icon(Icons.auto_awesome, color: Colors.white, size: 22),
                 label: Text(
                   isDesktop ? 'AI Generate Shopping List' : 'AI Generate',
                   style: TextStyle(
                     color: Colors.white,
                     fontWeight: FontWeight.bold,
                     fontSize: 15,
                     letterSpacing: 0.5,
                     shadows: [
                       // Main shadow for depth
                       Shadow(
                         offset: const Offset(1, 1),
                         blurRadius: 2,
                         color: Colors.black.withValues(alpha: 0.4),
                       ),
                       // Highlight shadow for 3D effect
                       Shadow(
                         offset: const Offset(-0.5, -0.5),
                         blurRadius: 1,
                         color: Colors.white.withValues(alpha: 0.3),
                       ),
                     ],
                   ),
                 ),
               ),
             ),
       floatingActionButtonLocation: isDesktop
           ? FloatingActionButtonLocation.endFloat
           : FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildDesktopLayout(List<String> categories, Map<String, List<ShoppingListItem>> groupedItems, String userId) {
    // Desktop: Show list on left, stores on right
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Shopping List (Left side)
        Expanded(
          flex: 2,
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(
              dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse},
            ),
            child: ScrollbarTheme(
              data: ScrollbarThemeData(
                thumbVisibility: WidgetStateProperty.all(false),
                trackVisibility: WidgetStateProperty.all(false),
              ),
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final categoryItems = groupedItems[category]!;
                  return CategorySectionWidget(
                    category: category,
                    items: categoryItems,
                    userId: userId,
                  );
                },
              ),
            ),
          ),
        ),

        // Suggested Stores (Right sidebar)
        if (_suggestedStores.isNotEmpty)
          Container(
            width: 320,
            padding: const EdgeInsets.all(24),
            child: StoreSuggestionsWidget(
              suggestedStores: _suggestedStores,
              isCompact: false,
            ),
          ),
      ],
    );
  }

  Widget _buildMobileLayout(List<String> categories, Map<String, List<ShoppingListItem>> groupedItems, String userId) {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(
        dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse},
      ),
      child: ScrollbarTheme(
        data: ScrollbarThemeData(
          thumbVisibility: WidgetStateProperty.all(false),
          trackVisibility: WidgetStateProperty.all(false),
        ),
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
          // Suggested Stores at top for mobile
          if (_suggestedStores.isNotEmpty) ...[
            StoreSuggestionsWidget(
              suggestedStores: _suggestedStores,
              isCompact: true,
            ),
            const SizedBox(height: 20),
          ],

          // Shopping list items
          ...categories.map((category) {
            final categoryItems = groupedItems[category]!;
            return CategorySectionWidget(
              category: category,
              items: categoryItems,
              userId: userId,
            );
          }),
        ],
        ),
      ),
    );
  }

  void _showClearCheckedDialog(BuildContext context) {
    final user = _authService.currentUser;
    if (user == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Checked Items'),
        content: const Text('Remove all checked items from your shopping list?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _firestoreService.clearCheckedItems(user.uid);
              if (!mounted) return;
              // ignore: use_build_context_synchronously
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Checked items cleared'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showRemoveAllDialog(BuildContext context) {
    final user = _authService.currentUser;
    if (user == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove All Items'),
        content: const Text('Are you sure you want to remove ALL items from your shopping list? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _firestoreService.clearShoppingList(user.uid);
              // Clear suggested stores from Firestore
              await _firestoreService.clearSuggestedStores(user.uid);
              setState(() {
                _suggestedStores = [];
              });
              if (!mounted) return;
              // ignore: use_build_context_synchronously
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All items removed'),
                  duration: Duration(seconds: 2),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('Remove All', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }


  Future<void> _generateShoppingList(BuildContext context) async {
    final user = _authService.currentUser;
    if (user == null) return;

    setState(() {
      _isGenerating = true;
    });

    try {
      // Show loading dialog
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667eea)),
              ),
              const SizedBox(height: 20),
              const Text(
                'AI is generating your shopping list...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Based on your fridge and preferences',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );

      // Fetch user profile and fridge items
      final userProfile = await _firestoreService.getUserProfile(user.uid);
      final fridgeItemsSnapshot = await _firestoreService
          .getFridgeItems(user.uid)
          .first;

      if (userProfile == null) {
        throw Exception('User profile not found');
      }

      // Extract ingredient names from fridge items
      final currentIngredients = fridgeItemsSnapshot.map((item) => item.name).toList();

      // Clear existing shopping list before generating new one
      await _firestoreService.clearShoppingList(user.uid);

      // Call AI service to generate shopping list
      final aiResponse = await _openAIService.generateShoppingList(
        currentIngredients,
        userProfile.dietaryRestrictions,
        userProfile.cuisinePreferences,
        userProfile.servingSize,
      );

      final aiGeneratedItems = aiResponse['items'] as List;
      final aiGeneratedStores = aiResponse['stores'] as List;

      if (aiGeneratedItems.isEmpty) {
        throw Exception('AI could not generate shopping list suggestions');
      }

      // Convert AI items to ShoppingListItem models
      final shoppingListItems = aiGeneratedItems.map((itemData) {
        final item = itemData as Map<String, dynamic>;
        return ShoppingListItem(
          id: '', // Firestore will generate ID
          name: item['name'] as String? ?? '',
          category: item['category'] as String? ?? 'Other',
          quantity: item['quantity'] as String? ?? '1',
          isChecked: false,
          createdAt: DateTime.now(),
        );
      }).toList();

      // Update suggested stores
      final stores = aiGeneratedStores.map((storeData) {
        final store = storeData as Map<String, dynamic>;
        return {
          'name': store['name'] as String? ?? '',
          'reason': store['reason'] as String? ?? '',
          'categories': (store['categories'] as List?)?.cast<String>() ?? <String>[],
        };
      }).toList();

      setState(() {
        _suggestedStores = stores;
      });

      // Save all items to Firestore
      await _firestoreService.addMultipleShoppingListItems(
        user.uid,
        shoppingListItems,
      );

      // Save suggested stores to Firestore
      await _firestoreService.saveSuggestedStores(user.uid, stores);

      // Close loading dialog and show success
      if (!mounted) return;
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();

      // Show success message
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added ${shoppingListItems.length} AI-suggested items'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'View',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
    } catch (e) {
      // Close loading dialog if open
      if (mounted) {
        // ignore: use_build_context_synchronously
        Navigator.of(context).pop();
      }

      // Show error message
      if (!mounted) return;
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }
}
