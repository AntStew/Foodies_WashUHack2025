import 'package:flutter/material.dart';
import 'recipe_generate_background.dart';

class RecipeGenerateFloatingButtons extends StatelessWidget {
  final VoidCallback onSaveRecipe;
  final VoidCallback onGenerateNew;

  const RecipeGenerateFloatingButtons({
    super.key,
    required this.onSaveRecipe,
    required this.onGenerateNew,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;
    
    if (isDesktop) {
      // Desktop: Positioned floating buttons
      return Positioned(
        bottom: 32,
        left: 32,
        right: 32,
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Row(
              children: [
                Expanded(
                  child: GradientButton(
                    onPressed: onSaveRecipe,
                    icon: Icons.save,
                    label: 'Save Recipe',
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade600, Colors.blue.shade800],
                    ),
                    glowColor: Colors.blue,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: GradientButton(
                    onPressed: onGenerateNew,
                    icon: Icons.refresh,
                    label: 'Generate New',
                    gradient: LinearGradient(
                      colors: [Colors.orange.shade400, Colors.orange.shade700],
                    ),
                    glowColor: Colors.orange,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      // Mobile: Fixed bottom buttons
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withValues(alpha: 0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: GradientButton(
                  onPressed: onSaveRecipe,
                  icon: Icons.save,
                  label: 'Save Recipe',
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade600, Colors.blue.shade800],
                  ),
                  glowColor: Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: GradientButton(
                  onPressed: onGenerateNew,
                  icon: Icons.refresh,
                  label: 'Generate New',
                  gradient: LinearGradient(
                    colors: [Colors.orange.shade400, Colors.orange.shade700],
                  ),
                  glowColor: Colors.orange,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}
