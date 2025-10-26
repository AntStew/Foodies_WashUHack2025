import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../models/fridge_item_model.dart';
import 'widgets/category_section_widget.dart';
import 'widgets/edit_item_dialog.dart';
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

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            'Not logged in',
            style: TextStyle(fontSize: 16, color: Color(0xFF718096)),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            // ===== Fixed Gradient AppBar =====
            Container(
              height: 110,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.fromARGB(255, 209, 38, 38),
                    Color.fromARGB(183, 255, 124, 30),
                    Color.fromARGB(0, 255, 255, 255),
                  ],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
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
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.bookmark_rounded, color: Colors.black),
                        tooltip: 'Saved Recipes',
                        onPressed: () {
                          Navigator.pushNamed(context, '/saved-recipes');
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.shopping_cart_outlined, color: Colors.black),
                        tooltip: 'Shopping List',
                        onPressed: () {
                          Navigator.pushNamed(context, '/shopping-list');
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout, color: Colors.black),
                        tooltip: 'Sign Out',
                        onPressed: () async {
                          await _authService.signOut();
                          if (!mounted) return;
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ===== Static Fridge Content =====
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
                              Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
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
                      if (items.isEmpty) return const EmptyStateWidget();

                      // Filter and group items
                      final filteredItems = items.where((item) {
                        return !_isSearching ||
                            item.name.toLowerCase().contains(_searchController.text.toLowerCase());
                      }).toList();

                      if (filteredItems.isEmpty) return const NoResultsWidget();

                      return Padding(
                        padding: EdgeInsets.only(
                          left: isDesktop ? 32 : 16,
                          right: isDesktop ? 32 : 16,
                          top: 16,
                          bottom: 16,
                        ),
                        child: CategorySectionWidget(
                          items: filteredItems,
                          onDeleteItem: (item) =>
                              _showDeleteItemDialog(context, item),
                          onEditItem: (item) =>
                              _showEditItemDialog(context, item),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // ===== Fixed Bottom Action Bar =====
            _buildBottomActionBar(context, user),
          ],
        ),
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
                        ? () => Navigator.pushNamed(context, '/recipe_generate')
                        : null,
                    icon: const Icon(Icons.restaurant_menu_rounded, color: Colors.white),
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

  void _showEditItemDialog(BuildContext context, FridgeItem item) async {
    try {
      final result = await showDialog<FridgeItem>(
        context: context,
        builder: (context) => EditItemDialog(item: item),
      );

      if (result != null) {
        try {
          await _firestoreService.updateFridgeItem(
            _authService.currentUser!.uid,
            item.id,
            {
              'name': result.name,
              'category': result.category,
              'quantity': result.quantity,
            },
          );

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${result.name} updated successfully'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        } catch (e) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error updating item: ${e.toString()}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error opening edit dialog: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
