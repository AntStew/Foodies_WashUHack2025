import 'package:flutter/material.dart';
import 'dart:ui';
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
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Gradient Background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.fromARGB(255, 209, 38, 38),
                    Color.fromARGB(255, 255, 124, 30),
                    Color.fromARGB(255, 255, 152, 60),
                  ],
                ),
              ),
            ),
          ),
          // Main Content
          SafeArea(
            child: Column(
              children: [
                // ===== Glassy Header =====
                ClipRRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      height: 110,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withValues(alpha: 0.15),
                            Colors.white.withValues(alpha: 0.05),
                          ],
                        ),
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.white.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                            child: Container(
                              height: 45,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  width: 1,
                                ),
                              ),
                              child: TextField(
                                controller: _searchController,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Search ingredients...',
                                  hintStyle: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.7),
                                    fontSize: 14,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.search_rounded,
                                    color: Colors.white.withValues(alpha: 0.8),
                                    size: 20,
                                  ),
                                  suffixIcon: _searchController.text.isNotEmpty
                                      ? IconButton(
                                          icon: Icon(
                                            Icons.clear_rounded,
                                            color: Colors.white.withValues(alpha: 0.8),
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
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.bookmark_rounded, color: Colors.white),
                        tooltip: 'Saved Recipes',
                        onPressed: () {
                          Navigator.pushNamed(context, '/saved-recipes');
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
                        tooltip: 'Shopping List',
                        onPressed: () {
                          Navigator.pushNamed(context, '/shopping-list');
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout, color: Colors.white),
                        tooltip: 'Sign Out',
                        onPressed: () async {
                          final navigator = Navigator.of(context);
                          await _authService.signOut();
                          if (!mounted) return;
                          navigator.pushReplacementNamed('/login');
                        },
                      ),
                    ],
                  ),
                ),
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
                                  Colors.white,
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

        return ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.15),
                    Colors.white.withValues(alpha: 0.05),
                  ],
                ),
                border: Border(
                  top: BorderSide(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
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
                          backgroundColor: Colors.white.withValues(alpha: 0.25),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 1,
                            ),
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
                          backgroundColor: Colors.white.withValues(alpha: 0.25),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.white.withValues(alpha: 0.1),
                          disabledForegroundColor: Colors.white.withValues(alpha: 0.5),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
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
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text('${result.name} updated successfully'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        } catch (e) {
          if (!mounted) return;
          scaffoldMessenger.showSnackBar(
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
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Error opening edit dialog: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
