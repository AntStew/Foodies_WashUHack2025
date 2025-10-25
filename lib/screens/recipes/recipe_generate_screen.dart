import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../services/openai_service.dart';
import '../../models/recipe_model.dart';

class RecipeGenerateScreen extends StatefulWidget {
  const RecipeGenerateScreen({super.key});

  @override
  State<RecipeGenerateScreen> createState() => _RecipeGenerateScreenState();
}

class _RecipeGenerateScreenState extends State<RecipeGenerateScreen> {
  final _authService = AuthService();
  final _firestoreService = FirestoreService();
  final _openAiService = OpenAIService();

  bool _isGenerating = false;
  Recipe? _generatedRecipe;

  Future<void> _generateRecipe() async {
    final user = _authService.currentUser;
    if (user == null) return;

    setState(() {
      _isGenerating = true;
      _generatedRecipe = null;
    });

    try {
      // Get user preferences
      final userProfile = await _firestoreService.getUserProfile(user.uid);

      // Get fridge items
      final fridgeItemsSnapshot = await _firestoreService.getFridgeItems(user.uid).first;

      if (fridgeItemsSnapshot.isEmpty) {
        throw Exception('Your fridge is empty! Add some items first.');
      }

      final ingredients = fridgeItemsSnapshot.map((item) => item.name).toList();

      // Generate recipe
      final recipeData = await _openAiService.generateRecipe(
        ingredients,
        userProfile?.dietaryRestrictions ?? [],
        userProfile?.cuisinePreferences ?? [],
        userProfile?.servingSize ?? 2,
      );

      if (recipeData == null) {
        throw Exception('Failed to generate recipe');
      }

      // Create Recipe object
      final recipe = Recipe(
        id: '',
        title: recipeData['title'] ?? 'Untitled Recipe',
        description: recipeData['description'] ?? '',
        cuisine: recipeData['cuisine'] ?? '',
        prepTime: recipeData['prepTime'] ?? '',
        cookTime: recipeData['cookTime'] ?? '',
        servings: recipeData['servings'] ?? 2,
        ingredients: List<String>.from(recipeData['ingredients'] ?? []),
        instructions: List<String>.from(recipeData['instructions'] ?? []),
        usedIngredients: List<String>.from(recipeData['usedIngredients'] ?? []),
        savedAt: DateTime.now(),
        imageUrl: recipeData['imageUrl'],
      );

      setState(() {
        _generatedRecipe = recipe;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

  Future<void> _saveRecipe() async {
    if (_generatedRecipe == null) return;

    final user = _authService.currentUser;
    if (user == null) return;

    try {
      await _firestoreService.saveRecipe(user.uid, _generatedRecipe!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recipe saved!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate Recipe'),
        actions: [
          if (_generatedRecipe != null)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveRecipe,
            ),
        ],
      ),
      body: _isGenerating
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Generating your recipe...'),
                  SizedBox(height: 8),
                  Text('This may take a moment', style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : _generatedRecipe == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.restaurant_menu, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text(
                          'Generate a recipe based on your fridge items',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton.icon(
                          onPressed: _generateRecipe,
                          icon: const Icon(Icons.auto_awesome),
                          label: const Text('Generate Recipe'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Recipe Image
                      if (_generatedRecipe!.imageUrl != null) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CachedNetworkImage(
                            imageUrl: _generatedRecipe!.imageUrl!,
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
                        _generatedRecipe!.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _generatedRecipe!.description,
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        children: [
                          Chip(label: Text(_generatedRecipe!.cuisine)),
                          Chip(label: Text('Prep: ${_generatedRecipe!.prepTime}')),
                          Chip(label: Text('Cook: ${_generatedRecipe!.cookTime}')),
                          Chip(label: Text('${_generatedRecipe!.servings} servings')),
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
                      ..._generatedRecipe!.ingredients.map((ingredient) => Padding(
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
                      ...List.generate(_generatedRecipe!.instructions.length, (index) {
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
                                child: Text(_generatedRecipe!.instructions[index]),
                              ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _saveRecipe,
                          icon: const Icon(Icons.save),
                          label: const Text('Save Recipe'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _generateRecipe,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Generate Another'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.all(16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
