import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../services/openai_service.dart';
import '../../models/shopping_list_item_model.dart';
import '../../routes/app_routes.dart';

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

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 800;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, AppRoutes.home);
          },
        ),
        title: const Text(
          'Shopping List',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        iconTheme: const IconThemeData(color: Color(0xFF2D3748)),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep, color: Color(0xFF718096)),
            tooltip: 'Clear checked items',
            onPressed: () => _showClearCheckedDialog(context),
          ),
        ],
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
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
      floatingActionButtonLocation: isDesktop
          ? FloatingActionButtonLocation.endFloat
          : FloatingActionButtonLocation.endFloat,
      body: user == null
          ? const Center(
              child: Text(
                'Not logged in',
                style: TextStyle(fontSize: 16, color: Color(0xFF718096)),
              ),
            )
          : StreamBuilder<List<ShoppingListItem>>(
              stream: _firestoreService.getShoppingList(user.uid),
              builder: (context, snapshot) {
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

                if (items.isEmpty) {
                  return _buildEmptyState();
                }

                // Group items by category
                final groupedItems = <String, List<ShoppingListItem>>{};
                for (final item in items) {
                  groupedItems.putIfAbsent(item.category, () => []).add(item);
                }

                final sortedCategories = groupedItems.keys.toList()..sort();

                return Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isDesktop ? 1200 : double.infinity,
                    ),
                    child: isDesktop
                        ? _buildDesktopLayout(sortedCategories, groupedItems)
                        : _buildMobileLayout(sortedCategories, groupedItems),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildDesktopLayout(List<String> categories, Map<String, List<ShoppingListItem>> groupedItems) {
    // Create a grid layout for desktop with 2 columns
    final leftColumnCategories = <String>[];
    final rightColumnCategories = <String>[];

    for (int i = 0; i < categories.length; i++) {
      if (i % 2 == 0) {
        leftColumnCategories.add(categories[i]);
      } else {
        rightColumnCategories.add(categories[i]);
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              children: leftColumnCategories.map((category) {
                return _buildCategorySection(category, groupedItems[category]!);
              }).toList(),
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              children: rightColumnCategories.map((category) {
                return _buildCategorySection(category, groupedItems[category]!);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(List<String> categories, Map<String, List<ShoppingListItem>> groupedItems) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final categoryItems = groupedItems[category]!;
        return _buildCategorySection(category, categoryItems);
      },
    );
  }

  Widget _buildEmptyState() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 800;

    return Center(
      child: Container(
        padding: EdgeInsets.all(isDesktop ? 48 : 24),
        constraints: BoxConstraints(
          maxWidth: isDesktop ? 600 : double.infinity,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(isDesktop ? 32 : 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF667eea).withValues(alpha: 0.15),
                    const Color(0xFF764ba2).withValues(alpha: 0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(isDesktop ? 80 : 60),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF667eea).withValues(alpha: 0.2),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(
                Icons.auto_awesome,
                size: isDesktop ? 96 : 72,
                color: const Color(0xFF667eea),
              ),
            ),
            SizedBox(height: isDesktop ? 40 : 32),
            Text(
              'Your shopping list is empty',
              style: TextStyle(
                fontSize: isDesktop ? 28 : 22,
                fontWeight: FontWeight.w700,
                color: Colors.grey[800],
                letterSpacing: 0.3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Tap the AI Generate button to get personalized shopping suggestions',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: isDesktop ? 18 : 16,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF667eea).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF667eea).withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.lightbulb_outline,
                    color: Color(0xFF667eea),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'AI analyzes your fridge & preferences',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection(String category, List<ShoppingListItem> items) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 800;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isDesktop ? 20 : 15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: isDesktop ? 15 : 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(isDesktop ? 20 : 16),
            decoration: BoxDecoration(
              gradient: _getCategoryGradient(category),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(isDesktop ? 20 : 15),
                topRight: Radius.circular(isDesktop ? 20 : 15),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getCategoryIcon(category),
                    color: Colors.white,
                    size: isDesktop ? 24 : 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  category,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isDesktop ? 20 : 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${items.length} ${items.length == 1 ? 'item' : 'items'}',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: isDesktop ? 15 : 14,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Items List
          ...items.map((item) => _buildShoppingListItem(item)),
        ],
      ),
    );
  }

  Widget _buildShoppingListItem(ShoppingListItem item) {
    final user = _authService.currentUser;
    if (user == null) return const SizedBox.shrink();

    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: const BoxDecoration(
          color: Colors.red,
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        _firestoreService.deleteShoppingListItem(user.uid, item.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${item.name} removed from list'),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.grey[200]!,
              width: 1,
            ),
          ),
        ),
        child: CheckboxListTile(
          value: item.isChecked,
          onChanged: (bool? value) {
            if (value != null) {
              _firestoreService.toggleShoppingListItem(user.uid, item.id, value);
            }
          },
          title: Text(
            item.name,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              decoration: item.isChecked ? TextDecoration.lineThrough : null,
              color: item.isChecked ? Colors.grey : const Color(0xFF2D3748),
            ),
          ),
          subtitle: Text(
            item.quantity,
            style: TextStyle(
              fontSize: 14,
              color: item.isChecked ? Colors.grey : const Color(0xFF718096),
              decoration: item.isChecked ? TextDecoration.lineThrough : null,
            ),
          ),
          activeColor: const Color(0xFF667eea),
          controlAffinity: ListTileControlAffinity.leading,
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

  LinearGradient _getCategoryGradient(String category) {
    switch (category.toLowerCase()) {
      case 'produce':
      case 'vegetables':
      case 'fruits':
        return const LinearGradient(colors: [Colors.green, Colors.lightGreen]);
      case 'dairy':
        return const LinearGradient(colors: [Colors.blue, Colors.lightBlue]);
      case 'meat':
        return const LinearGradient(colors: [Colors.red, Colors.deepOrange]);
      case 'pantry':
      case 'grains':
        return const LinearGradient(colors: [Colors.brown, Colors.amber]);
      default:
        return const LinearGradient(colors: [Colors.grey, Colors.blueGrey]);
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'produce':
      case 'vegetables':
      case 'fruits':
        return Icons.eco;
      case 'dairy':
        return Icons.local_drink;
      case 'meat':
        return Icons.restaurant;
      case 'pantry':
      case 'grains':
        return Icons.kitchen;
      default:
        return Icons.shopping_bag;
    }
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

      // Call AI service to generate shopping list
      final aiGeneratedItems = await _openAIService.generateShoppingList(
        currentIngredients,
        userProfile.dietaryRestrictions,
        userProfile.cuisinePreferences,
        userProfile.servingSize,
      );

      if (aiGeneratedItems.isEmpty) {
        throw Exception('AI could not generate shopping list suggestions');
      }

      // Convert AI items to ShoppingListItem models
      final shoppingListItems = aiGeneratedItems.map((item) {
        return ShoppingListItem(
          id: '', // Firestore will generate ID
          name: item['name'] ?? '',
          category: item['category'] ?? 'Other',
          quantity: item['quantity'] ?? '1',
          isChecked: false,
          createdAt: DateTime.now(),
        );
      }).toList();

      // Save all items to Firestore
      await _firestoreService.addMultipleShoppingListItems(
        user.uid,
        shoppingListItems,
      );

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
