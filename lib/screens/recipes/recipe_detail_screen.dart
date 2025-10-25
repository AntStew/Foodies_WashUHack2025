import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/recipe_model.dart';

class RecipeDetailScreen extends StatelessWidget {
  final Recipe recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recipe Image
            if (recipe.imageUrl != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: recipe.imageUrl!,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(Icons.error, size: 50),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Text(
              recipe.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              recipe.description,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                Chip(label: Text(recipe.cuisine)),
                Chip(label: Text('Prep: ${recipe.prepTime}')),
                Chip(label: Text('Cook: ${recipe.cookTime}')),
                Chip(label: Text('${recipe.servings} servings')),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Ingredients',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...recipe.ingredients.map((ingredient) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.circle, size: 8),
                      const SizedBox(width: 8),
                      Expanded(child: Text(ingredient)),
                    ],
                  ),
                )),
            const SizedBox(height: 24),
            const Text(
              'Instructions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...List.generate(recipe.instructions.length, (index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 12,
                      child: Text('${index + 1}'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(recipe.instructions[index]),
                    ),
                  ],
                ),
              );
            }),
            if (recipe.usedIngredients.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Text(
                'Used from Your Fridge',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: recipe.usedIngredients
                    .map((ingredient) => Chip(label: Text(ingredient)))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
