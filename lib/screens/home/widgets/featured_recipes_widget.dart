import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:ui';
import '../../../models/recipe_model.dart';

class FeaturedRecipesWidget extends StatelessWidget {
  final List<Recipe> recipes;
  final VoidCallback onGenerateRecipe;
  final Function(Recipe) onRecipeTap;

  const FeaturedRecipesWidget({
    super.key,
    required this.recipes,
    required this.onGenerateRecipe,
    required this.onRecipeTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color.fromARGB(255, 209, 38, 38),
                      Color.fromARGB(255, 255, 124, 30),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: Colors.white, size: 24),
                    const SizedBox(width: 12),
                    const Text(
                      'Featured Recipes',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: Builder(
                  builder: (context) {
                    return recipes.isEmpty
                        ? _buildEmptyState(context)
                        : _buildRecipeGrid(context);
                  },
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant_menu_rounded,
              size: 64,
              color: Colors.white.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 16),
            Text(
              'No Saved Recipes Yet',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Generate your first recipe from your fridge items',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onGenerateRecipe,
              icon: const Icon(Icons.auto_awesome, color: Colors.white),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
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
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeGrid(BuildContext context) {
    // Show up to 5 most recent recipes
    final displayRecipes = recipes.take(5).toList();

    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(
        dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse},
      ),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        scrollDirection: Axis.horizontal,
        itemCount: displayRecipes.length,
        itemBuilder: (context, index) {
          final recipe = displayRecipes[index];
          return Container(
            width: 280,
            margin: EdgeInsets.only(
              right: index < displayRecipes.length - 1 ? 16 : 0,
            ),
            child: _RecipeCard3D(
              recipe: recipe,
              onTap: () => onRecipeTap(recipe),
            ),
          );
        },
      ),
    );
  }
}

class _RecipeCard3D extends StatefulWidget {
  final Recipe recipe;
  final VoidCallback onTap;

  const _RecipeCard3D({required this.recipe, required this.onTap});

  @override
  State<_RecipeCard3D> createState() => _RecipeCard3DState();
}

class _RecipeCard3DState extends State<_RecipeCard3D>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _hoverScaleAnimation;
  late Animation<double> _hoverElevationAnimation;
  late Animation<double> _hoverGlowAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _hoverScaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeOutCubic),
    );
    _hoverElevationAnimation = Tween<double>(begin: 0.0, end: 8.0).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeOutCubic),
    );
    _hoverGlowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
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
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _hoverController,
          builder: (context, child) {
            return Transform.scale(
              scale: _hoverScaleAnimation.value,
              child: Transform.translate(
                offset: Offset(0, -_hoverElevationAnimation.value),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      // Hover glow effect
                      if (_isHovered)
                        BoxShadow(
                          color: Colors.orange.withValues(
                            alpha: 0.3 * _hoverGlowAnimation.value,
                          ),
                          blurRadius: 20 * _hoverGlowAnimation.value,
                          offset: Offset(0, 8 * _hoverGlowAnimation.value),
                          spreadRadius: 3 * _hoverGlowAnimation.value,
                        ),
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: 0.15 + 0.1 * _hoverGlowAnimation.value,
                        ),
                        blurRadius: 15 + 10 * _hoverGlowAnimation.value,
                        offset: Offset(0, 6 + 4 * _hoverGlowAnimation.value),
                        spreadRadius: 1 + 2 * _hoverGlowAnimation.value,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Stack(
                        children: [
                          // Background Image - optimized with CachedNetworkImage
                          if (widget.recipe.imageUrl != null &&
                              widget.recipe.imageUrl!.isNotEmpty)
                            Positioned.fill(
                              child: CachedNetworkImage(
                                imageUrl: widget.recipe.imageUrl!,
                                fit: BoxFit.cover,
                                memCacheWidth: 600, // Resize for performance
                                memCacheHeight: 400,
                                placeholder: (context, url) => Container(
                                  color: Colors.grey.shade800,
                                ),
                                errorWidget: (context, url, error) {
                                  return _buildFallbackBackground();
                                },
                              ),
                            )
                          else
                            _buildFallbackBackground(),

                          // Gradient Overlay
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withValues(alpha: 0.3),
                                    Colors.black.withValues(alpha: 0.8),
                                  ],
                                  stops: const [0.0, 0.6, 1.0],
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
                                      fontSize: 14,
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
                                      color: Colors.white.withValues(
                                        alpha: 0.9,
                                      ),
                                      fontSize: 11,
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
                                      _buildInfoChip(
                                        widget.recipe.cuisine,
                                        Icons.restaurant,
                                      ),
                                      _buildInfoChip(
                                        '${widget.recipe.servings}',
                                        Icons.people,
                                      ),
                                      _buildInfoChip(
                                        '${widget.recipe.prepTime + widget.recipe.cookTime}m',
                                        Icons.access_time,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Favorite indicator
                          if (widget.recipe.isFavorite)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.red.withValues(alpha: 0.9),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.red.withValues(alpha: 0.4),
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.favorite,
                                  color: Colors.white,
                                  size: 14,
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
      ),
      child: const Center(
        child: Icon(Icons.restaurant, color: Colors.white, size: 40),
      ),
    );
  }

  Widget _buildInfoChip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 10),
          const SizedBox(width: 3),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              shadows: [
                Shadow(
                  color: Colors.black26,
                  offset: Offset(0, 1),
                  blurRadius: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
