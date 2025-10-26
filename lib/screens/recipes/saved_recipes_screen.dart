import 'package:flutter/material.dart';
import 'dart:ui';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../models/recipe_model.dart';
import 'recipe_detail_screen.dart';

class SavedRecipesScreen extends StatefulWidget {
  const SavedRecipesScreen({super.key});

  @override
  State<SavedRecipesScreen> createState() => _SavedRecipesScreenState();
}

class _SavedRecipesScreenState extends State<SavedRecipesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCuisine = 'All';
  String _selectedSortBy = 'Recently Added';
  bool _showFilters = false;

  final List<String> _cuisines = [
    'All',
    'Italian',
    'Mexican',
    'Asian',
    'American',
    'Indian',
    'Mediterranean',
    'French',
    'Chinese',
    'Japanese',
    'Thai',
    'Other'
  ];

  final List<String> _sortOptions = [
    'Recently Added',
    'Alphabetical A-Z',
    'Alphabetical Z-A',
    'Cooking Time',
    'Servings'
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Recipe> _filterAndSortRecipes(List<Recipe> recipes) {
    // Early return if no filters applied
    if (_searchQuery.isEmpty && _selectedCuisine == 'All' && _selectedSortBy == 'Recently Added') {
      return recipes;
    }

    List<Recipe> filtered = recipes.where((recipe) {
      // Search filter
      bool matchesSearch = _searchQuery.isEmpty ||
          recipe.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          recipe.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          recipe.cuisine.toLowerCase().contains(_searchQuery.toLowerCase());

      // Cuisine filter
      bool matchesCuisine = _selectedCuisine == 'All' || recipe.cuisine == _selectedCuisine;

      return matchesSearch && matchesCuisine;
    }).toList();

    // Sort recipes only if needed
    if (_selectedSortBy != 'Recently Added') {
      switch (_selectedSortBy) {
        case 'Alphabetical A-Z':
          filtered.sort((a, b) => a.title.compareTo(b.title));
          break;
        case 'Alphabetical Z-A':
          filtered.sort((a, b) => b.title.compareTo(a.title));
          break;
        case 'Cooking Time':
          filtered.sort((a, b) {
            int timeA = _extractTimeInMinutes(a.prepTime);
            int timeB = _extractTimeInMinutes(b.prepTime);
            return timeA.compareTo(timeB);
          });
          break;
        case 'Servings':
          filtered.sort((a, b) => b.servings.compareTo(a.servings));
          break;
      }
    }

    return filtered;
  }

  int _extractTimeInMinutes(String timeString) {
    // Extract numbers from strings like "30 min", "1 hour", "45 minutes"
    final RegExp regex = RegExp(r'(\d+)');
    final match = regex.firstMatch(timeString);
    if (match != null) {
      int value = int.parse(match.group(1)!);
      if (timeString.toLowerCase().contains('hour')) {
        return value * 60;
      }
      return value;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final firestoreService = FirestoreService();
    final user = authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            // Home button
            IconButton(
              icon: const Icon(
                Icons.home,
                color: Colors.white,
                size: 24,
              ),
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/home',
                  (route) => false,
                );
              },
            ),
            const SizedBox(width: 8),
            // Search bar (takes up remaining space)
            Expanded(
              child: _buildSearchBar(),
            ),
            const SizedBox(width: 8),
            // Filter button
            _buildFilterButton(),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0.15),
                    Colors.white.withOpacity(0.05),
                  ],
                ),
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'design/background/foodbg.jpg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.orange.shade300,
                        Colors.orange.shade500,
                        Colors.orange.shade700,
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Dark overlay for better text readability
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.6),
                  ],
                ),
              ),
            ),
          ),
          // Main content
          user == null
              ? const Center(
                  child: Text(
                    'Not logged in',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              : StreamBuilder<List<Recipe>>(
                  stream: firestoreService.getSavedRecipes(user.uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error: ${snapshot.error}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      );
                    }

                    final allRecipes = snapshot.data ?? [];
                    final filteredRecipes = _filterAndSortRecipes(allRecipes);

                    if (allRecipes.isEmpty) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.book,
                              size: 64,
                              color: Colors.white70,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No saved recipes yet',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Generate some recipes to get started',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    if (filteredRecipes.isEmpty) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: Colors.white70,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No recipes found',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Try adjusting your search or filters',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return LayoutBuilder(
                      builder: (context, constraints) {
                        // Calculate grid columns based on screen width
                        int crossAxisCount;
                        if (constraints.maxWidth < 600) {
                          crossAxisCount = 2; // Mobile: 2x2 grid
                        } else if (constraints.maxWidth < 900) {
                          crossAxisCount = 3; // Tablet: 3x3 grid
                        } else {
                          crossAxisCount = 4; // Desktop: 4x4 grid
                        }

                        return GridView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 100, 16, 16), // Add top padding for app bar
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            childAspectRatio: 0.8,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: filteredRecipes.length,
                          itemBuilder: (context, index) {
                            final recipe = filteredRecipes[index];
                            return _buildRecipeCard(context, recipe, firestoreService, user.uid);
                          },
                        );
                      },
                    );
                  },
                ),
          // Filter Popup Overlay
          if (_showFilters) _buildFilterPopup(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                if (_searchQuery != value) {
                  setState(() {
                    _searchQuery = value;
                  });
                }
              },
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: 'Search recipes...',
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.white.withOpacity(0.8),
                  size: 20,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: Colors.white.withOpacity(0.8),
                          size: 16,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showFilters = !_showFilters;
        });
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.filter_list,
                color: Colors.white.withOpacity(0.9),
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterPopup() {
    return Positioned.fill(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _showFilters = false;
          });
        },
        child: Container(
          color: Colors.black.withOpacity(0.5),
          child: Center(
            child: GestureDetector(
              onTap: () {}, // Prevent closing when tapping on the popup itself
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.8,
                  maxWidth: 400,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Filters',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _showFilters = false;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      Icons.close,
                                      color: Colors.white.withOpacity(0.9),
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            // Cuisine Filter
                            Text(
                              'Cuisine',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: _cuisines.map((cuisine) {
                                final isSelected = _selectedCuisine == cuisine;
                                return GestureDetector(
                                onTap: () {
                                  if (_selectedCuisine != cuisine) {
                                    setState(() {
                                      _selectedCuisine = cuisine;
                                    });
                                  }
                                },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? Colors.orange.withOpacity(0.8)
                                          : Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: isSelected
                                            ? Colors.orange
                                            : Colors.white.withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      cuisine,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 20),
                            // Sort Filter
                            Text(
                              'Sort By',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: _sortOptions.map((sortOption) {
                                final isSelected = _selectedSortBy == sortOption;
                                return GestureDetector(
                                onTap: () {
                                  if (_selectedSortBy != sortOption) {
                                    setState(() {
                                      _selectedSortBy = sortOption;
                                    });
                                  }
                                },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? Colors.orange.withOpacity(0.8)
                                          : Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: isSelected
                                            ? Colors.orange
                                            : Colors.white.withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      sortOption,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 20),
                            // Apply Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _showFilters = false;
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange.withOpacity(0.8),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 0,
                                ),
                                child: const Text(
                                  'Apply Filters',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecipeCard(BuildContext context, Recipe recipe, FirestoreService firestoreService, String uid) {
    return _RecipeCard3D(
      recipe: recipe,
      firestoreService: firestoreService,
      uid: uid,
    );
  }
}

class _RecipeCard3D extends StatefulWidget {
  final Recipe recipe;
  final FirestoreService firestoreService;
  final String uid;

  const _RecipeCard3D({
    required this.recipe,
    required this.firestoreService,
    required this.uid,
  });

  @override
  State<_RecipeCard3D> createState() => _RecipeCard3DState();
}

class _RecipeCard3DState extends State<_RecipeCard3D> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  late Animation<double> _hoverScaleAnimation;
  late Animation<double> _hoverElevationAnimation;
  late Animation<double> _hoverGlowAnimation;
  bool _isPressed = false;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _elevationAnimation = Tween<double>(begin: 0.0, end: -5.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    // Hover animations
    _hoverScaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeOutCubic),
    );
    _hoverElevationAnimation = Tween<double>(begin: 0.0, end: 15.0).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeOutCubic),
    );
    _hoverGlowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _hoverController.dispose();
    super.dispose();
  }

  void _onHoverEnter() {
    if (!_isPressed) {
      setState(() {
        _isHovered = true;
      });
      _hoverController.forward();
    }
  }

  void _onHoverExit() {
    setState(() {
      _isHovered = false;
    });
    _hoverController.reverse();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() {
      _isPressed = true;
    });
    _animationController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() {
      _isPressed = false;
    });
    _animationController.reverse();
  }

  void _onTapCancel() {
    setState(() {
      _isPressed = false;
    });
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 300),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.9 + (0.1 * value),
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: Opacity(
              opacity: value,
              child: MouseRegion(
                onEnter: (_) => _onHoverEnter(),
                onExit: (_) => _onHoverExit(),
                child: GestureDetector(
                  onTapDown: _onTapDown,
                  onTapUp: _onTapUp,
                  onTapCancel: _onTapCancel,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RecipeDetailScreen(recipe: widget.recipe),
                      ),
                    );
                  },
                  child: AnimatedBuilder(
                    animation: Listenable.merge([_animationController, _hoverController]),
                    builder: (context, child) {
                      // Combine hover and press animations
                      final combinedScale = _isPressed
                          ? _scaleAnimation.value
                          : _hoverScaleAnimation.value;
                      final combinedElevation = _isPressed
                          ? _elevationAnimation.value
                          : _hoverElevationAnimation.value;

                      return Transform.scale(
                        scale: combinedScale,
                        child: Transform.translate(
                          offset: Offset(0, combinedElevation),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                // Hover glow effect
                                if (_isHovered && !_isPressed)
                                  BoxShadow(
                                    color: Colors.orange.withOpacity(0.3 * _hoverGlowAnimation.value),
                                    blurRadius: 25 * _hoverGlowAnimation.value,
                                    offset: Offset(0, 10 * _hoverGlowAnimation.value),
                                    spreadRadius: 5 * _hoverGlowAnimation.value,
                                  ),
                                // Dynamic shadow based on press state and hover
                                BoxShadow(
                                  color: Colors.black.withOpacity(
                                    _isPressed ? 0.25 : (0.15 + 0.1 * _hoverGlowAnimation.value)
                                  ),
                                  blurRadius: _isPressed ? 15 : (20 + 10 * _hoverGlowAnimation.value),
                                  offset: Offset(0, _isPressed ? 4 : (8 + 5 * _hoverGlowAnimation.value)),
                                  spreadRadius: _isPressed ? 1 : (2 + 2 * _hoverGlowAnimation.value),
                                ),
                                BoxShadow(
                                  color: Colors.black.withOpacity(
                                    _isPressed ? 0.15 : (0.1 + 0.05 * _hoverGlowAnimation.value)
                                  ),
                                  blurRadius: _isPressed ? 30 : (40 + 15 * _hoverGlowAnimation.value),
                                  offset: Offset(0, _isPressed ? 8 : (16 + 8 * _hoverGlowAnimation.value)),
                                  spreadRadius: _isPressed ? 2 : (4 + 3 * _hoverGlowAnimation.value),
                                ),
                                BoxShadow(
                                  color: Colors.black.withOpacity(
                                    _isPressed ? 0.08 : (0.05 + 0.03 * _hoverGlowAnimation.value)
                                  ),
                                  blurRadius: _isPressed ? 45 : (60 + 20 * _hoverGlowAnimation.value),
                                  offset: Offset(0, _isPressed ? 12 : (24 + 12 * _hoverGlowAnimation.value)),
                                  spreadRadius: _isPressed ? 3 : (6 + 4 * _hoverGlowAnimation.value),
                                ),
                                // Inner highlight with hover enhancement
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.15 + 0.1 * _hoverGlowAnimation.value),
                                  blurRadius: 2 + 1 * _hoverGlowAnimation.value,
                                  offset: const Offset(0, -1),
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    // Background Image
                                    if (widget.recipe.imageUrl != null && widget.recipe.imageUrl!.isNotEmpty)
                                      Positioned.fill(
                                        child: Image.network(
                                          widget.recipe.imageUrl!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return _buildFallbackBackground();
                                          },
                                        ),
                                      )
                                    else
                                      _buildFallbackBackground(),

                                    // 3D Gradient Overlay with multiple layers
                                    Positioned.fill(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Colors.transparent,
                                              Colors.black.withOpacity(0.3),
                                              Colors.black.withOpacity(0.8),
                                            ],
                                            stops: const [0.0, 0.6, 1.0],
                                          ),
                                        ),
                                      ),
                                    ),

                                    // Additional depth overlay
                                    Positioned.fill(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(20),
                                          gradient: RadialGradient(
                                            center: Alignment.topLeft,
                                            radius: 1.5,
                                            colors: [
                                              Colors.white.withOpacity(0.1),
                                              Colors.transparent,
                                              Colors.black.withOpacity(0.2),
                                            ],
                                            stops: const [0.0, 0.3, 1.0],
                                          ),
                                        ),
                                      ),
                                    ),

                                    // Content
                                    Positioned(
                                      bottom: 0,
                                      left: 0,
                                      right: 0,
                                      child: Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            // Title
                                            Text(
                                              widget.recipe.title,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                shadows: [
                                                  Shadow(
                                                    color: Colors.black54,
                                                    offset: Offset(0, 1),
                                                    blurRadius: 2,
                                                  ),
                                                ],
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),

                                            // Description
                                            Text(
                                              widget.recipe.description,
                                              style: TextStyle(
                                                color: Colors.white.withOpacity(0.9),
                                                fontSize: 12,
                                                shadows: const [
                                                  Shadow(
                                                    color: Colors.black45,
                                                    offset: Offset(0, 1),
                                                    blurRadius: 1,
                                                  ),
                                                ],
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 8),

                                            // Recipe Info Chips
                                            Wrap(
                                              spacing: 4,
                                              runSpacing: 4,
                                              children: [
                                                _buildInfoChip(widget.recipe.cuisine, Icons.restaurant),
                                                _buildInfoChip('${widget.recipe.servings} servings', Icons.people),
                                                _buildInfoChip(widget.recipe.prepTime, Icons.access_time),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    // 3D Delete Button
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: GestureDetector(
                                        onTap: () => _showDeleteDialog(context, widget.recipe, widget.firestoreService, widget.uid),
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.red.withOpacity(0.9),
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.red.withOpacity(0.4),
                                                blurRadius: 8,
                                                offset: const Offset(0, 4),
                                              ),
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.2),
                                                blurRadius: 4,
                                                offset: const Offset(0, 2),
                                              ),
                                              // Inner highlight
                                              BoxShadow(
                                                color: Colors.white.withOpacity(0.3),
                                                blurRadius: 1,
                                                offset: const Offset(0, -1),
                                              ),
                                            ],
                                          ),
                                          child: const Icon(
                                            Icons.delete,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFallbackBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.orange.shade300,
            Colors.orange.shade500,
            Colors.orange.shade700,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          // 3D effect overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topLeft,
                  radius: 1.0,
                  colors: [
                    Colors.white.withOpacity(0.2),
                    Colors.transparent,
                    Colors.black.withOpacity(0.1),
                  ],
                ),
              ),
            ),
          ),
          const Center(
            child: Icon(
              Icons.restaurant,
              color: Colors.white,
              size: 48,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String text, IconData icon) {
    return _HoverableChip(
      text: text,
      icon: icon,
    );
  }

  Future<void> _showDeleteDialog(BuildContext context, Recipe recipe, FirestoreService firestoreService, String uid) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Recipe'),
        content: const Text(
          'Are you sure you want to delete this recipe?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await firestoreService.deleteRecipe(uid, recipe.id);
    }
  }
}

class _HoverableChip extends StatefulWidget {
  final String text;
  final IconData icon;

  const _HoverableChip({
    required this.text,
    required this.icon,
  });

  @override
  State<_HoverableChip> createState() => _HoverableChipState();
}

class _HoverableChipState extends State<_HoverableChip> with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeOutCubic),
    );
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  void _onHoverEnter() {
    setState(() {
      _isHovered = true;
    });
    _hoverController.forward();
  }

  void _onHoverExit() {
    setState(() {
      _isHovered = false;
    });
    _hoverController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _onHoverEnter(),
      onExit: (_) => _onHoverExit(),
      child: AnimatedBuilder(
        animation: _hoverController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25 + 0.1 * _glowAnimation.value),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.4 + 0.2 * _glowAnimation.value),
                  width: 1,
                ),
                boxShadow: [
                  // Enhanced shadow on hover
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2 + 0.1 * _glowAnimation.value),
                    blurRadius: 4 + 2 * _glowAnimation.value,
                    offset: Offset(0, 2 + 1 * _glowAnimation.value),
                  ),
                  // Glow effect
                  if (_isHovered)
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.3 * _glowAnimation.value),
                      blurRadius: 8 * _glowAnimation.value,
                      offset: const Offset(0, 0),
                      spreadRadius: 2 * _glowAnimation.value,
                    ),
                  // Inner highlight
                  BoxShadow(
                    color: Colors.white.withOpacity(0.3 + 0.2 * _glowAnimation.value),
                    blurRadius: 1 + 1 * _glowAnimation.value,
                    offset: const Offset(0, -1),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.icon,
                    color: Colors.white,
                    size: 12,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    widget.text,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      shadows: [
                        Shadow(
                          color: Colors.black26,
                          offset: const Offset(0, 1),
                          blurRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}