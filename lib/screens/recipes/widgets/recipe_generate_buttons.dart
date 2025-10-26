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
    
    return Positioned(
      bottom: isDesktop ? 32 : 24,
      left: isDesktop ? 32 : 24,
      right: isDesktop ? 32 : 24,
      child: Center(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: isDesktop ? 600 : double.infinity,
          ),
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
              SizedBox(width: isDesktop ? 20 : 16),
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
  }
}
