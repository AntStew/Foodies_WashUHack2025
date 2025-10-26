import 'package:flutter/material.dart';

class IngredientStatusSection extends StatelessWidget {
  final List<String> availableIngredients;
  final List<String> missingIngredients;

  const IngredientStatusSection({
    super.key,
    required this.availableIngredients,
    required this.missingIngredients,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ingredient Status',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),

        // Available Ingredients
        if (availableIngredients.isNotEmpty) ...[
          Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green.shade300, size: 20),
              const SizedBox(width: 8),
              Text(
                'You Have (${availableIngredients.length})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: availableIngredients
                .map((ing) => AvailableIngredientBadge(ingredient: ing))
                .toList(),
          ),
          const SizedBox(height: 20),
        ],

        // Missing Ingredients
        if (missingIngredients.isNotEmpty) ...[
          Row(
            children: [
              Icon(Icons.cancel, color: Colors.red.shade300, size: 20),
              const SizedBox(width: 8),
              Text(
                'You Need (${missingIngredients.length})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: missingIngredients
                .map((ing) => MissingIngredientBadge(ingredient: ing))
                .toList(),
          ),
        ],

        // All ingredients available
        if (missingIngredients.isEmpty && availableIngredients.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade400, Colors.green.shade600],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.celebration, color: Colors.white),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Perfect! You have all ingredients!',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class AvailableIngredientBadge extends StatelessWidget {
  final String ingredient;

  const AvailableIngredientBadge({
    super.key,
    required this.ingredient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade400, Colors.green.shade600],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, color: Colors.white, size: 14),
          const SizedBox(width: 6),
          Text(
            ingredient,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class MissingIngredientBadge extends StatelessWidget {
  final String ingredient;

  const MissingIngredientBadge({
    super.key,
    required this.ingredient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red.shade400, Colors.red.shade600],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cancel, color: Colors.white, size: 14),
          const SizedBox(width: 6),
          Text(
            ingredient,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
