import 'package:cloud_firestore/cloud_firestore.dart';

class Recipe {
  final String id;
  final String title;
  final String description;
  final List<String> ingredients;
  final List<String> instructions;
  final String prepTime;
  final String cookTime;
  final int servings;
  final String cuisine;
  final DateTime savedAt;
  final bool isFavorite;
  final List<String> usedIngredients;

  Recipe({
    required this.id,
    required this.title,
    required this.description,
    required this.ingredients,
    required this.instructions,
    required this.prepTime,
    required this.cookTime,
    required this.servings,
    required this.cuisine,
    required this.savedAt,
    this.isFavorite = false,
    this.usedIngredients = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'ingredients': ingredients,
      'instructions': instructions,
      'prepTime': prepTime,
      'cookTime': cookTime,
      'servings': servings,
      'cuisine': cuisine,
      'savedAt': Timestamp.fromDate(savedAt),
      'isFavorite': isFavorite,
      'usedIngredients': usedIngredients,
      'generatedBy': 'openai',
    };
  }

  factory Recipe.fromMap(String id, Map<String, dynamic> map) {
    return Recipe(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      ingredients: List<String>.from(map['ingredients'] ?? []),
      instructions: List<String>.from(map['instructions'] ?? []),
      prepTime: map['prepTime'] ?? '',
      cookTime: map['cookTime'] ?? '',
      servings: map['servings'] ?? 2,
      cuisine: map['cuisine'] ?? '',
      savedAt: (map['savedAt'] as Timestamp).toDate(),
      isFavorite: map['isFavorite'] ?? false,
      usedIngredients: List<String>.from(map['usedIngredients'] ?? []),
    );
  }

  Recipe copyWith({bool? isFavorite}) {
    return Recipe(
      id: id,
      title: title,
      description: description,
      ingredients: ingredients,
      instructions: instructions,
      prepTime: prepTime,
      cookTime: cookTime,
      servings: servings,
      cuisine: cuisine,
      savedAt: savedAt,
      isFavorite: isFavorite ?? this.isFavorite,
      usedIngredients: usedIngredients,
    );
  }
}
