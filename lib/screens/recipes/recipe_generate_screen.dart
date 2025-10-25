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

        //Generated Recipe View
                    : SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Builder(builder: (context) {
                      // local state for instruction slider that will persist while this build remains
                      final instructions = _generatedRecipe!.instructions;
                      int currentInstructionIndex = 0;
                
                      return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      // Header image (full width)
                      if (_generatedRecipe!.imageUrl != null) ...[
                      ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(
                      imageUrl: _generatedRecipe!.imageUrl!,
                      width: double.infinity,
                      height: 220,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                      height: 220,
                      color: Colors.grey[300],
                      child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                      height: 220,
                      color: Colors.grey[300],
                      child: const Center(child: Icon(Icons.error, size: 50)),
                      ),
                      ),
                      ),
                      const SizedBox(height: 16),
                      ],
                
                      // Title & description
                      Text(
                      _generatedRecipe!.title,
                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                      _generatedRecipe!.description,
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 12),
                
                      // Chips (cuisine, prep, cook, servings)
                      Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                      Chip(label: Text('Style: ${_generatedRecipe!.cuisine.isEmpty ? "—" : _generatedRecipe!.cuisine}')),
                      Chip(label: Text('Prep: ${_generatedRecipe!.prepTime.isEmpty ? "—" : _generatedRecipe!.prepTime}')),
                      Chip(label: Text('Cook: ${_generatedRecipe!.cookTime.isEmpty ? "—" : _generatedRecipe!.cookTime}')),
                      Chip(label: Text('Servings: ${_generatedRecipe!.servings}')),
                      ],
                      ),
                      const SizedBox(height: 20),
                
                      const SizedBox(height: 24),
                
                      // Ingredients - grid table with 3 columns (cells shrink to fit text, centered)
                      const Text('Ingredients', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Builder(builder: (context) {
                      final int columns = 3;
                      final double outerHorizontalPadding = 24 * 2; // matches parent SingleChildScrollView padding
                      final double totalWidth = MediaQuery.of(context).size.width - outerHorizontalPadding;
                      const double spacing = 12;
                      final double itemWidth = (totalWidth - (spacing * (columns - 1))) / columns;
                
                      return Wrap(
                      spacing: spacing,
                      runSpacing: spacing,
                      children: _generatedRecipe!.ingredients.map((ingredient) {
                      return SizedBox(
                      width: itemWidth,
                      child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Center(
                        child: Text(
                        ingredient,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      ),
                      );
                      }).toList(),
                    );
                    }),
                    const SizedBox(height: 24),
                
                    // Instructions slider (one step at a time with back/forward)
                    const Text('Instructions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                
                    // Use a StatefulBuilder so the slider state (currentInstructionIndex) can be updated
                    StatefulBuilder(builder: (context, setInnerState) {
                    // Display current instruction safely
                    final int idx = currentInstructionIndex.clamp(0, (instructions.isEmpty ? 0 : instructions.length - 1));
                    final String instructionText = instructions.isEmpty ? 'No instructions available.' : instructions[idx];
                
                    // compute half-width of the window for the centered card
                    // and enforce a minimum width so the card stops shrinking further.
                    // If the min width is larger than available space, allow horizontal scroll.
                    const double minCardWidth = 320.0;
                    const double smallWindowThreshold = 800.0;
                    const double fixedCardWidthForSmall = 400.0; // when window <= 800px, keep slider at this width
                
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                      // Use LayoutBuilder to inspect available width and decide sizing/scrolling behavior
                      LayoutBuilder(builder: (context, constraints) {
                      final double desiredWidth = constraints.maxWidth * 0.5;
                      double cardWidth;
                      // Prevent the slider box from shrinking when the window width is 800px or less:
                      if (constraints.maxWidth <= smallWindowThreshold) {
                        cardWidth = fixedCardWidthForSmall;
                      } else {
                        cardWidth = desiredWidth < minCardWidth ? minCardWidth : desiredWidth;
                      }
                
                      // If cardWidth would exceed available constraints, wrap in a horizontal scroll view
                      final Widget card = SizedBox(
                      width: cardWidth,
                      height: 200,
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                        // top step label (kept)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                          Text('Step ${idx + 1} of ${instructions.length}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: SingleChildScrollView(
                          child: Text(instructionText, style: const TextStyle(fontSize: 16)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // navigation controls positioned at the bottom of the card
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                          ElevatedButton.icon(
                          onPressed: idx > 0
                            ? () {
                            setInnerState(() {
                            currentInstructionIndex = idx - 1;
                            });
                            }
                            : null,
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('Back'),
                          ),
                          // Dots moved to the center where the page counter used to be
                          Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(instructions.length, (dotIdx) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            child: Container(
                            width: dotIdx == idx ? 10 : 6,
                            height: dotIdx == idx ? 10 : 6,
                            decoration: BoxDecoration(
                            color: dotIdx == idx ? Theme.of(context).colorScheme.primary : Colors.grey[400],
                            shape: BoxShape.circle,
                            ),
                            ),
                          );
                          }),
                          ),
                          ElevatedButton.icon(
                          onPressed: idx < instructions.length - 1
                            ? () {
                            setInnerState(() {
                            currentInstructionIndex = idx + 1;
                            });
                            }
                            : null,
                          icon: const Icon(Icons.arrow_forward),
                          label: const Text('Next'),
                          ),
                          ],
                        ),
                        ],
                        ),
                        ),
                      ),
                      );
                
                      // If the desired card width is larger than the available width, allow horizontal scrolling
                      if (cardWidth > constraints.maxWidth) {
                      return Center(
                        child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: card,
                        ),
                      );
                      } else {
                      return Center(child: card);
                      }
                      }),
                      const SizedBox(height: 24),
                
                      // Action buttons (save / generate another) placed under Instructions slider
                      Row(
                      children: [
                      Expanded(
                        child: ElevatedButton.icon(
                        onPressed: _saveRecipe,
                        icon: const Icon(Icons.save),
                        label: const Text('Save Recipe'),
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: _generateRecipe,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Generate Another'),
                        style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                        minimumSize: const Size(120, 48),
                        ),
                      ),
                      ],
                      ),
                      const SizedBox(height: 32),
                      ],
                    );
                    }),
                
                      ],
                      );
                      }), // end Builder
                    ), // end SingleChildScrollView
                    ); // end Scaffold
                } // end build
                } // end class
