import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../models/fridge_item_model.dart';
import 'widgets/action_buttons_widget.dart';
import 'widgets/search_bar_widget.dart';
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
        title: const Text(
          'My Fridge',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFF718096)),
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
          : Stack(
              children: [
                // Main Content
                Column(
                  children: [
                    // Action Buttons
                    const ActionButtonsWidget(),

                    const SizedBox(height: 100), // Space for floating search bar

                    // Fridge Items Display
                    Expanded(
                      child: StreamBuilder<List<FridgeItem>>(
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
                            padding: const EdgeInsets.all(16),
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
                      ),
                    ),
                  ],
                ),

                // Floating Search Bar
                Positioned(
                  top: 120,
                  left: 16,
                  right: 16,
                  child: SearchBarWidget(
                    controller: _searchController,
                    isSearching: _isSearching,
                    onChanged: (value) {
                      setState(() {
                        _isSearching = value.isNotEmpty;
                      });
                    },
                    onClear: () {
                      setState(() {
                        _searchController.clear();
                        _isSearching = false;
                      });
                    },
                  ),
                ),
              ],
            ),
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
