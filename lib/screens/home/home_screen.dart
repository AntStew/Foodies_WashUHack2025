import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../models/fridge_item_model.dart';
import 'widgets/category_section_widget.dart';
import 'widgets/empty_state_widget.dart';
import 'widgets/no_results_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authService = AuthService();
  final _firestoreService = FirestoreService();
  final _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        title: Row(
          children: [
            Expanded(
              child: Container(
                height: 45,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search ingredients...',
                    hintStyle: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 14,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: Colors.grey[600],
                      size: 20,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.clear_rounded,
                              color: Colors.grey[600],
                              size: 18,
                            ),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                _isSearching = false;
                              });
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _isSearching = value.isNotEmpty;
                    });
                  },
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_rounded, color: Color(0xFF667eea)),
            tooltip: 'Saved Recipes',
            onPressed: () {
              Navigator.pushNamed(context, '/saved-recipes');
            },
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined, color: Color(0xFF667eea)),
            tooltip: 'Shopping List',
            onPressed: () {
              Navigator.pushNamed(context, '/shopping-list');
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFF718096)),
            tooltip: 'Sign Out',
            onPressed: () async {
              await _authService.signOut();
              if (!mounted) return;
              // ignore: use_build_context_synchronously
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: user == null
          ? const Center(
              child: Text(
                'Not logged in',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF718096),
                ),
              ),
            )
          : Column(
              children: [
                // Fridge Items Display
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isDesktop = constraints.maxWidth > 800;

                      return StreamBuilder<List<FridgeItem>>(
                        stream: _firestoreService.getFridgeItems(user.uid),
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
                            return const EmptyStateWidget();
                          }

                          // Filter items based on search
                          final filteredItems = items.where((item) {
                            return !_isSearching || 
                                item.name.toLowerCase().contains(_searchController.text.toLowerCase());
                          }).toList();

                          if (filteredItems.isEmpty) {
                            return const NoResultsWidget();
                          }

                          // Group items by category
                          final groupedItems = <String, List<FridgeItem>>{};
                          for (final item in filteredItems) {
                            groupedItems.putIfAbsent(item.category, () => []).add(item);
                          }

                          // Sort categories to prioritize meat, vegetables, dairy, then others
                          final sortedCategories = groupedItems.keys.toList()
                            ..sort((a, b) {
                              final aLower = a.toLowerCase();
                              final bLower = b.toLowerCase();
                              
                              // Priority order: meat, vegetables, dairy, then alphabetical, then other
                              final aPriority = _getCategoryPriority(aLower);
                              final bPriority = _getCategoryPriority(bLower);
                              
                              if (aPriority != bPriority) {
                                return aPriority.compareTo(bPriority);
                              }
                              
                              if (aLower == 'other') return 1;
                              if (bLower == 'other') return -1;
                              return a.compareTo(b);
                            });

                          return ListView.builder(
                            padding: EdgeInsets.only(
                              left: isDesktop ? 32 : 16,
                              right: isDesktop ? 32 : 16,
                              top: 16,
                              bottom: 100, // Add padding for fixed bottom bar
                            ),
                            itemCount: sortedCategories.length,
                            itemBuilder: (context, index) {
                              final category = sortedCategories[index];
                              final categoryItems = groupedItems[category]!;
                              return CategorySectionWidget(
                                category: category,
                                items: categoryItems,
                                onDeleteItem: (item) => _showDeleteItemDialog(context, item),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),

                // Fixed Bottom Action Bar
                _buildBottomActionBar(context, user),
              ],
            ),
    );
  }

  Widget _buildBottomActionBar(BuildContext context, user) {
    return StreamBuilder<List<FridgeItem>>(
      stream: _firestoreService.getFridgeItems(user.uid),
      builder: (context, snapshot) {
        final items = snapshot.data ?? [];
        final hasItems = items.isNotEmpty;

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/scan-fridge');
                    },
                    icon: Icon(
                      hasItems ? Icons.refresh : Icons.camera_alt_rounded,
                      color: Colors.white,
                    ),
                    label: Text(
                      hasItems ? 'Rescan Fridge' : 'Scan Fridge',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF667eea),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: hasItems
                        ? () {
                            Navigator.pushNamed(context, '/generate-recipe');
                          }
                        : null,
                    icon: const Icon(
                      Icons.restaurant_menu_rounded,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Generate Recipe',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF764ba2),
                      disabledBackgroundColor: Colors.grey[300],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  int _getCategoryPriority(String category) {
    switch (category.toLowerCase()) {
      case 'meat':
        return 1;
      case 'vegetables':
        return 2;
      case 'dairy':
        return 3;
      case 'fruits':
        return 4;
      case 'grains':
        return 5;
      case 'beverages':
        return 6;
      case 'other':
        return 99;
      default:
        return 50; // Other categories in alphabetical order
    }
  }


  void _showDeleteItemDialog(BuildContext context, FridgeItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: Text('Are you sure you want to delete "${item.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _firestoreService.deleteFridgeItem(_authService.currentUser!.uid, item.id);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

}
