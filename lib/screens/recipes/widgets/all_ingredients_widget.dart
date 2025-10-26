import 'package:flutter/material.dart';
import '../../../models/recipe_model.dart';

class AllIngredientsSection extends StatelessWidget {
  final Recipe recipe;

  const AllIngredientsSection({
    super.key,
    required this.recipe,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width <= 800;
    final columns = isMobile ? 2 : 3;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'All Ingredients',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            const double spacing = 12;
            final double itemWidth =
                (constraints.maxWidth - (spacing * (columns - 1))) / columns;
                
            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: recipe.ingredients.map((ingredient) {
                return SizedBox(
                  width: itemWidth,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      ingredient,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white,
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}
