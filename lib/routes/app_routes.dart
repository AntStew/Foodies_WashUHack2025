import 'package:flutter/material.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/auth/questionnaire_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/fridge/fridge_scan_screen.dart';
import '../screens/recipes/recipe_generate_screen.dart';
import '../screens/recipes/saved_recipes_screen.dart';
import '../screens/shopping/shopping_list_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String signup = '/signup';
  static const String questionnaire = '/questionnaire';
  static const String home = '/home';
  static const String scanFridge = '/scan-fridge';
  static const String generateRecipe = '/generate-recipe';
  static const String savedRecipes = '/saved-recipes';
  static const String shoppingList = '/shopping-list';

  static Map<String, WidgetBuilder> routes = {
    login: (context) => const LoginScreen(),
    signup: (context) => const SignupScreen(),
    questionnaire: (context) => const QuestionnaireScreen(),
    home: (context) => const HomeScreen(),
    scanFridge: (context) => const FridgeScanScreen(),
    generateRecipe: (context) => const RecipeGenerateScreen(),
    savedRecipes: (context) => const SavedRecipesScreen(),
    shoppingList: (context) => const ShoppingListScreen(),
  };
}
