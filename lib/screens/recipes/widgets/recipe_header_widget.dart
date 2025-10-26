import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../models/recipe_model.dart';

class GlassyPanel extends StatelessWidget {
  final Widget child;

  const GlassyPanel({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(0),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.all(32),
            child: child,
          ),
        ),
      ),
    );
  }
}

class RecipeHeader extends StatelessWidget {
  final Recipe recipe;
  final bool isCompact;

  const RecipeHeader({
    super.key,
    required this.recipe,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;
    final useCompactLayout = isCompact || isDesktop;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title with accent line
        Container(
          padding: const EdgeInsets.only(left: 4),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: Colors.orange.shade400,
                width: 4,
              ),
            ),
          ),
          child: Text(
            recipe.title,
            style: TextStyle(
              fontSize: useCompactLayout ? 24 : 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
        ),
        SizedBox(height: useCompactLayout ? 12 : 16),
        Text(
          recipe.description,
          style: TextStyle(
            fontSize: useCompactLayout ? 15 : 17,
            color: Colors.white.withValues(alpha: 0.95),
            height: 1.5,
          ),
        ),
        SizedBox(height: useCompactLayout ? 16 : 20),
        Wrap(
          spacing: useCompactLayout ? 8 : 10,
          runSpacing: useCompactLayout ? 8 : 10,
          children: [
            InfoChip(
              icon: Icons.restaurant,
              label: recipe.cuisine.isEmpty ? 'Style: —' : recipe.cuisine,
              isCompact: useCompactLayout,
            ),
            InfoChip(
              icon: Icons.access_time,
              label: recipe.prepTime.isEmpty ? 'Prep: —' : 'Prep ${recipe.prepTime}',
              isCompact: useCompactLayout,
            ),
            InfoChip(
              icon: Icons.timer,
              label: recipe.cookTime.isEmpty ? 'Cook: —' : 'Cook ${recipe.cookTime}',
              isCompact: useCompactLayout,
            ),
            InfoChip(
              icon: Icons.people,
              label: '${recipe.servings} Servings',
              isCompact: useCompactLayout,
            ),
          ],
        ),
      ],
    );
  }
}

class InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isCompact;

  const InfoChip({
    super.key,
    required this.icon,
    required this.label,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 12 : 14,
        vertical: isCompact ? 8 : 10,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.2),
            Colors.white.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(isCompact ? 20 : 24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: isCompact ? 16 : 18),
          SizedBox(width: isCompact ? 6 : 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: isCompact ? 12 : 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
