import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../services/openai_service.dart';
import '../../models/recipe_model.dart';
import '../../models/fridge_item_model.dart';
import '../../utils/logger.dart';
import 'widgets/recipe_generate_background.dart';
import 'widgets/recipe_header_widget.dart';
import 'widgets/ingredient_status_widget.dart';
import 'widgets/all_ingredients_widget.dart';
import 'widgets/instructions_widget.dart';
import 'widgets/recipe_generate_buttons.dart';
import 'widgets/recipe_generation_form.dart';

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
  List<String> _availableIngredients = [];
  List<String> _missingIngredients = [];
  String _additionalContext = '';
  MealType _selectedMealType = MealType.dinner;

  Future<void> _generateRecipe() async {
    final user = _authService.currentUser;
    if (user == null) return;

    setState(() {
      _isGenerating = true;
      _generatedRecipe = null;
      _availableIngredients = [];
      _missingIngredients = [];
    });

    try {
      // Get user preferences
      final userProfile = await _firestoreService.getUserProfile(user.uid);

      // Get fridge items
      List<FridgeItem> fridgeItemsSnapshot;
      try {
        fridgeItemsSnapshot = await _firestoreService.getFridgeItems(user.uid).first;
      } catch (e) {
        if (e.toString().contains('TimeoutException')) {
          throw Exception('Unable to load fridge items. Please check your internet connection and try again.');
        } else {
          throw Exception('Failed to load fridge items: ${e.toString()}');
        }
      }

      if (fridgeItemsSnapshot.isEmpty) {
        throw Exception('Your fridge is empty! Add some items first.');
      }

      final ingredients =
          fridgeItemsSnapshot.map((item) => item.name).toList();

      // Generate recipe
      AppLogger.info('Recipe generation parameters:');
      AppLogger.info('Additional context: "$_additionalContext"');
      AppLogger.info('Selected meal type: ${_selectedMealType.name}');
      
      final recipeData = await _openAiService.generateRecipe(
        ingredients,
        userProfile?.dietaryRestrictions ?? [],
        userProfile?.cuisinePreferences ?? [],
        userProfile?.servingSize ?? 2,
        additionalContext: _additionalContext,
        mealType: _selectedMealType.name,
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
        usedIngredients:
            List<String>.from(recipeData['usedIngredients'] ?? []),
        savedAt: DateTime.now(),
        imageUrl: recipeData['imageUrl'],
      );

      setState(() {
        _generatedRecipe = recipe;
      });

      // Categorize ingredients after recipe is generated
      await _categorizeIngredients();
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

  Future<void> _categorizeIngredients() async {
    final user = _authService.currentUser;
    if (user == null || _generatedRecipe == null) return;

    // Get user's fridge items
    List<FridgeItem> fridgeItems;
    try {
      fridgeItems = await _firestoreService.getFridgeItems(user.uid).first;
    } catch (e) {
      // If we can't load fridge items, just skip categorization
      AppLogger.error('Failed to load fridge items for categorization: $e');
      return;
    }
    final userIngredients =
        fridgeItems.map((item) => item.name.toLowerCase()).toSet();

    List<String> available = [];
    List<String> missing = [];

    // Categorize recipe ingredients
    for (final ingredient in _generatedRecipe!.ingredients) {
      final ingredientLower = ingredient.toLowerCase();

      // Check if any fridge item matches (contains) this ingredient
      bool hasIngredient = userIngredients.any((userIng) =>
          ingredientLower.contains(userIng) || userIng.contains(ingredientLower));

      if (hasIngredient) {
        available.add(ingredient);
      } else {
        missing.add(ingredient);
      }
    }

    setState(() {
      _availableIngredients = available;
      _missingIngredients = missing;
    });
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

  void _handleFormSubmit(String context, MealType mealType) {
    AppLogger.info('Form submitted with:');
    AppLogger.info('Context: "$context"');
    AppLogger.info('Meal type: ${mealType.name}');
    
    setState(() {
      _additionalContext = context;
      _selectedMealType = mealType;
    });
    _generateRecipe();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: const Text('Generate Recipe'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/home');
            },
          ),
        ),
        body: _buildBody(isDesktop),
      ),
    );
  }

  Widget _buildBody(bool isDesktop) {
    if (_isGenerating) {
      return const LoadingStateBackground();
    }

    if (_generatedRecipe == null) {
      return Stack(
        children: [
          RecipeGenerateBackground(recipe: _generatedRecipe),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: RecipeGenerationForm(
                onFormSubmit: _handleFormSubmit,
                initialContext: _additionalContext,
                initialMealType: _selectedMealType,
              ),
            ),
          ),
        ],
      );
    }

    // Recipe content - different layout for mobile vs desktop
    if (isDesktop) {
      return Stack(
        children: [
          RecipeGenerateBackground(recipe: _generatedRecipe),
          _buildRecipeContent(isDesktop),
        ],
      );
    } else {
      // Mobile: Use a single scrollable view
      return Stack(
        children: [
          RecipeGenerateBackground(recipe: _generatedRecipe),
          _buildMobileScrollableContent(),
        ],
      );
    }
  }


  Widget _buildMobileScrollableContent() {
    return SafeArea(
      child: Column(
        children: [
          // Scrollable content area
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.5),
                    Colors.black.withValues(alpha: 0.8),
                  ],
                ),
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GlassyPanel(
                      child: RecipeHeader(recipe: _generatedRecipe!),
                    ),
                    const SizedBox(height: 16),
                    GlassyPanel(
                      child: IngredientStatusSection(
                        availableIngredients: _availableIngredients,
                        missingIngredients: _missingIngredients,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GlassyPanel(
                      child: AllIngredientsSection(recipe: _generatedRecipe!),
                    ),
                    const SizedBox(height: 16),
                    GlassyPanel(
                      child: InstructionsSection(recipe: _generatedRecipe!),
                    ),
                    const SizedBox(height: 100), // Space for bottom buttons
                  ],
                ),
              ),
            ),
          ),
          
          // Fixed bottom buttons
          Container(
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
                      onPressed: _saveRecipe,
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
                      onPressed: () {
                        // Reset the recipe and go back to form
                        AppLogger.info('Generate New clicked - resetting recipe');
                        AppLogger.info('Preserved context: "$_additionalContext"');
                        AppLogger.info('Preserved meal type: ${_selectedMealType.name}');
                        setState(() {
                          _generatedRecipe = null;
                          _availableIngredients = [];
                          _missingIngredients = [];
                        });
                      },
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
        ],
      ),
    );
  }

  Widget _buildRecipeContent(bool isDesktop) {
    return Stack(
      children: [
        // Gradient overlay for readability
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.5),
                  Colors.black.withValues(alpha: 0.8),
                ],
              ),
            ),
          ),
        ),

        // Scrollable Content
        SafeArea(
          child: _buildDesktopLayout(),
        ),

        // Floating Action Buttons
        RecipeGenerateFloatingButtons(
          onSaveRecipe: _saveRecipe,
          onGenerateNew: () {
            // Reset the recipe and go back to form
            AppLogger.info('Generate New clicked - resetting recipe');
            AppLogger.info('Preserved context: "$_additionalContext"');
            AppLogger.info('Preserved meal type: ${_selectedMealType.name}');
            setState(() {
              _generatedRecipe = null;
              _availableIngredients = [];
              _missingIngredients = [];
            });
          },
        ),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Panel - Recipe Header & Image (35% width)
          Expanded(
            flex: 2,
            child: Column(
              children: [
                // Recipe Header with Image
                GlassyPanel(
                  child: Column(
                    children: [
                      // Recipe Image
                      if (_generatedRecipe!.imageUrl != null && _generatedRecipe!.imageUrl!.isNotEmpty)
                        Container(
                          height: 300,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(
                              _generatedRecipe!.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Colors.orange.shade300, Colors.orange.shade600],
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.restaurant_menu,
                                      size: 64,
                                      color: Colors.white,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      if (_generatedRecipe!.imageUrl != null && _generatedRecipe!.imageUrl!.isNotEmpty)
                        const SizedBox(height: 24),
                      
                      // Recipe Header
                      RecipeHeader(recipe: _generatedRecipe!),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Ingredient Status
                GlassyPanel(
                  child: IngredientStatusSection(
                    availableIngredients: _availableIngredients,
                    missingIngredients: _missingIngredients,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 24),
          
          // Right Panel - Ingredients & Instructions (65% width)
          Expanded(
            flex: 3,
            child: Column(
              children: [
                // All Ingredients
                GlassyPanel(
                  child: AllIngredientsSection(recipe: _generatedRecipe!),
                ),
                const SizedBox(height: 24),
                
                // Instructions
                GlassyPanel(
                  child: InstructionsSection(recipe: _generatedRecipe!),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


}
