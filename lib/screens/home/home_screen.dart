import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:async';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../models/fridge_item_model.dart';
import '../../models/user_model.dart';
import '../../models/recipe_model.dart';
import '../../routes/app_routes.dart';
import 'widgets/category_section_widget.dart';
import 'widgets/edit_item_dialog.dart';
import 'widgets/empty_state_widget.dart';
import 'widgets/no_results_widget.dart';
import 'widgets/preferences_panel_widget.dart';
import 'widgets/featured_recipes_widget.dart';

// Data class to hold combined stream data
class _HomeData {
  final UserModel? userModel;
  final List<Recipe> recipes;
  final List<FridgeItem> fridgeItems;

  _HomeData({
    required this.userModel,
    required this.recipes,
    required this.fridgeItems,
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authService = AuthService();
  final _firestoreService = FirestoreService();
  final _searchController = TextEditingController();
  final _searchQuery = ValueNotifier<String>('');
  Timer? _debounceTimer;

  @override
  void dispose() {
    _searchController.dispose();
    _searchQuery.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  // Combine all streams into one to avoid nested StreamBuilders
  Stream<_HomeData> _getCombinedStream(String uid) {
    return _firestoreService.getFridgeItems(uid).asyncMap((fridgeItems) async {
      final userModel = await _firestoreService.getUserProfile(uid);
      final recipes = await _firestoreService.getSavedRecipes(uid).first;
      return _HomeData(
        userModel: userModel,
        recipes: recipes,
        fridgeItems: fridgeItems,
      );
    });
  }

  void _onSearchChanged(String value) {
    // Debounce search input
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _searchQuery.value = value;
    });
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
          // Background Image
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('design/background/fooood.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          // Dark overlay - replaced BackdropFilter with static overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
              ),
            ),
          ),
          // Main Content
          SafeArea(
            child: Column(
              children: [
                // ===== Optimized Header (removed BackdropFilter) =====
                _buildHeader(context, user),

                // ===== Split Content Area with SINGLE StreamBuilder =====
                Expanded(
                  child: StreamBuilder<_HomeData>(
                    stream: _getCombinedStream(user.uid),
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
                              const Icon(
                                Icons.error_outline,
                                size: 64,
                                color: Colors.redAccent,
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

                      final data = snapshot.data;
                      if (data == null || data.userModel == null) {
                        return const Center(
                          child: Text(
                            'Error loading data',
                            style: TextStyle(color: Colors.white),
                          ),
                        );
                      }

                      return _buildContent(
                        context,
                        user.uid,
                        data.userModel!,
                        data.recipes,
                        data.fridgeItems,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, user) {
    return Container(
      height: 110,
      decoration: BoxDecoration(
        // Static semi-transparent background instead of BackdropFilter
        color: Colors.black.withValues(alpha: 0.4),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              // Search Bar Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: Container(
                      height: 45,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(25),
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
                                    _searchController.clear();
                                    _searchQuery.value = '';
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                        onChanged: _onSearchChanged,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(
                      Icons.bookmark_rounded,
                      color: Colors.white,
                    ),
                    tooltip: 'Saved Recipes',
                    onPressed: () {
                      Navigator.pushNamed(context, '/saved-recipes');
                    },
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.shopping_cart_outlined,
                      color: Colors.white,
                    ),
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
              const SizedBox(height: 12),
              // Action Buttons Row - will be populated by StreamBuilder data
              _buildActionButtonsPlaceholder(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtonsPlaceholder(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.5,
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/scan-fridge');
                  },
                  icon: const Icon(Icons.camera_alt_rounded,
                      color: Colors.white, size: 16),
                  label: const Text(
                    'Scan',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.25),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/recipe_generate'),
                  icon: const Icon(
                    Icons.restaurant_menu_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                  label: const Text(
                    'Generate',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.25),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
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
      ],
    );
  }

  Widget _buildContent(
    BuildContext context,
    String userId,
    UserModel userModel,
    List<Recipe> recipes,
    List<FridgeItem> fridgeItems,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 800;
        final padding = isDesktop ? 32.0 : 16.0;

        return ValueListenableBuilder<String>(
          valueListenable: _searchQuery,
          builder: (context, searchQuery, _) {
            final filteredItems = fridgeItems.where((item) {
              return searchQuery.isEmpty ||
                  item.name.toLowerCase().contains(
                        searchQuery.toLowerCase(),
                      );
            }).toList();

            return Padding(
              padding: EdgeInsets.all(padding),
              child: isDesktop
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left half - Fridge Items
                        Expanded(
                          child: RepaintBoundary(
                            child: _buildFridgeContent(
                              fridgeItems,
                              filteredItems,
                              userId,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Right half - Split column
                        Expanded(
                          child: Column(
                            children: [
                              // Top: Preferences (50%)
                              Expanded(
                                child: RepaintBoundary(
                                  child: PreferencesPanelWidget(
                                    userModel: userModel,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Bottom: Featured Recipes (50%)
                              Expanded(
                                child: RepaintBoundary(
                                  child: FeaturedRecipesWidget(
                                    recipes: recipes,
                                    onGenerateRecipe: () {
                                      Navigator.pushNamed(
                                        context,
                                        AppRoutes.recipeGenerate,
                                      );
                                    },
                                    onRecipeTap: (recipe) {
                                      Navigator.pushNamed(
                                        context,
                                        AppRoutes.recipeDetail,
                                        arguments: recipe,
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : ScrollConfiguration(
                      behavior: ScrollConfiguration.of(context).copyWith(
                        dragDevices: {
                          PointerDeviceKind.touch,
                          PointerDeviceKind.mouse,
                        },
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            // Mobile: Preferences at top
                            SizedBox(
                              height: 300,
                              child: RepaintBoundary(
                                child: PreferencesPanelWidget(
                                  userModel: userModel,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Mobile: Featured Recipes
                            SizedBox(
                              height: 280,
                              child: RepaintBoundary(
                                child: FeaturedRecipesWidget(
                                  recipes: recipes,
                                  onGenerateRecipe: () {
                                    Navigator.pushNamed(
                                      context,
                                      AppRoutes.recipeGenerate,
                                    );
                                  },
                                  onRecipeTap: (recipe) {
                                    Navigator.pushNamed(
                                      context,
                                      AppRoutes.recipeDetail,
                                      arguments: recipe,
                                    );
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Mobile: Fridge Items
                            SizedBox(
                              height: 600,
                              child: RepaintBoundary(
                                child: _buildFridgeContent(
                                  fridgeItems,
                                  filteredItems,
                                  userId,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            );
          },
        );
      },
    );
  }

  Widget _buildFridgeContent(
    List<FridgeItem> allItems,
    List<FridgeItem> filteredItems,
    String userId,
  ) {
    if (allItems.isEmpty) {
      return const EmptyStateWidget();
    }

    if (filteredItems.isEmpty) {
      return const NoResultsWidget();
    }

    return CategorySectionWidget(
      items: filteredItems,
      onDeleteItem: (item) => _showDeleteItemDialog(context, item),
      onEditItem: (item) => _showEditItemDialog(context, item),
      onDeleteAll: () => _showDeleteAllDialog(context, userId),
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
              await _firestoreService.deleteFridgeItem(
                _authService.currentUser!.uid,
                item.id,
              );
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

  void _showDeleteAllDialog(BuildContext context, String userId) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      await _firestoreService.clearFridge(userId);

      if (!mounted) return;
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('All items deleted successfully'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Error deleting all items: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
