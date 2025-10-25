import 'package:cloud_functions/cloud_functions.dart';
import '../utils/logger.dart';

class OpenAIService {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  // Analyze fridge image and extract items using Cloud Function
  Future<List<Map<String, String>>> analyzeFridgeImage(String imageUrl) async {
    try {
      final callable = _functions.httpsCallable('analyzeFridgeImage');
      final result = await callable.call({'imageUrl': imageUrl});

      if (result.data['success'] == true) {
        final items = result.data['items'] as List;
        return items.map((item) => {
          'name': item['name'] as String,
          'category': item['category'] as String,
          'quantity': item['quantity'] as String,
          'freshness': item['freshness'] as String,
        }).toList();
      }

      return [];
    } catch (e) {
      AppLogger.error('Error analyzing fridge', e);
      return [];
    }
  }

  // Generate recipe based on available ingredients using Cloud Function
  Future<Map<String, dynamic>?> generateRecipe(
    List<String> ingredients,
    List<String> dietaryRestrictions,
    List<String> cuisinePreferences,
    int servings,
  ) async {
    try {
      final callable = _functions.httpsCallable('generateRecipe');
      final result = await callable.call({
        'ingredients': ingredients,
        'dietaryRestrictions': dietaryRestrictions,
        'cuisinePreferences': cuisinePreferences,
        'servings': servings,
      });

      if (result.data['success'] == true) {
        return result.data['recipe'] as Map<String, dynamic>;
      }

      return null;
    } catch (e) {
      AppLogger.error('Error generating recipe', e);
      return null;
    }
  }

  // Generate shopping list based on current fridge contents using Cloud Function
  Future<List<Map<String, String>>> generateShoppingList(
    List<String> currentIngredients,
    List<String> dietaryRestrictions,
    List<String> cuisinePreferences,
    int servingSize,
  ) async {
    try {
      final callable = _functions.httpsCallable('generateShoppingList');
      final result = await callable.call({
        'currentIngredients': currentIngredients,
        'dietaryRestrictions': dietaryRestrictions,
        'cuisinePreferences': cuisinePreferences,
        'servingSize': servingSize,
      });

      if (result.data['success'] == true) {
        final items = result.data['items'] as List;
        return items.map((item) => {
          'name': item['name'] as String,
          'category': item['category'] as String,
          'quantity': item['quantity'] as String,
        }).toList();
      }

      return [];
    } catch (e) {
      AppLogger.error('Error generating shopping list', e);
      return [];
    }
  }
}
