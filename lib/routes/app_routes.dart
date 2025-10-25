import 'package:flutter/material.dart';
import '../screens/landing_page/landing_page.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/auth/questionnaire_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/fridge/fridge_scan_screen.dart';
import '../screens/recipes/recipe_generate_screen.dart';
import '../screens/recipes/saved_recipes_screen.dart';
import '../screens/shopping/shopping_list_screen.dart';

class AppRoutes {
  static const landing = '/';
  static const login = '/login';
  static const signup = '/signup';
  static const questionnaire = '/questionnaire';
  static const home = '/home';
  static const String scanFridge = '/scan-fridge';
  static const String generateRecipe = '/generate-recipe';
  static const String savedRecipes = '/saved-recipes';
  static const recipeDetail = '/recipe_detail';
  static const recipeGenerate = '/recipe_generate';
  static const fridgeScan = '/fridge_scan';
  static const shoppingList = '/shopping-list';

  static Map<String, WidgetBuilder> routes = {
    landing: (_) => const LandingPage(),
    login: (_) => const LoginScreen(),
    signup: (_) => const SignupScreen(),
    questionnaire: (_) => const QuestionnaireScreen(),
    home: (_) => const HomeScreen(),
    scanFridge: (context) => const FridgeScanScreen(),
    recipeGenerate: (context) => const RecipeGenerateScreen(),
    savedRecipes: (context) => const SavedRecipesScreen(),
    shoppingList: (context) => const ShoppingListScreen(),
  };
}
