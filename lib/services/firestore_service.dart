import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../models/fridge_item_model.dart';
import '../models/recipe_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // User Profile Operations
  Future<void> createUserProfile(User user, String displayName) async {
    final userModel = UserModel(
      uid: user.uid,
      email: user.email ?? '',
      displayName: displayName,
    );

    await _db.collection('users').doc(user.uid).set(userModel.toMap());
  }

  Future<UserModel?> getUserProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data()!);
    }
    return null;
  }

  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).update(data);
  }

  Future<void> completeQuestionnaire(
    String uid,
    List<String> dietaryRestrictions,
    List<String> cuisinePreferences,
    List<String> allergies,
    int servingSize,
  ) async {
    await _db.collection('users').doc(uid).update({
      'questionnaireCompleted': true,
      'preferences': {
        'dietaryRestrictions': dietaryRestrictions,
        'cuisinePreferences': cuisinePreferences,
        'allergies': allergies,
        'servingSize': servingSize,
      }
    });
  }

  // Fridge Item Operations
  Stream<List<FridgeItem>> getFridgeItems(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('fridgeItems')
        .orderBy('addedDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FridgeItem.fromMap(doc.id, doc.data()))
            .toList());
  }

  Future<void> addFridgeItem(String uid, FridgeItem item) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('fridgeItems')
        .add(item.toMap());
  }

  Future<void> updateFridgeItem(String uid, String itemId, Map<String, dynamic> data) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('fridgeItems')
        .doc(itemId)
        .update(data);
  }

  Future<void> deleteFridgeItem(String uid, String itemId) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('fridgeItems')
        .doc(itemId)
        .delete();
  }

  Future<void> clearFridge(String uid) async {
    final batch = _db.batch();
    final items = await _db
        .collection('users')
        .doc(uid)
        .collection('fridgeItems')
        .get();

    for (var doc in items.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  // Recipe Operations
  Stream<List<Recipe>> getSavedRecipes(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('recipes')
        .orderBy('savedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Recipe.fromMap(doc.id, doc.data()))
            .toList());
  }

  Future<void> saveRecipe(String uid, Recipe recipe) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('recipes')
        .add(recipe.toMap());
  }

  Future<void> deleteRecipe(String uid, String recipeId) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('recipes')
        .doc(recipeId)
        .delete();
  }

  Future<void> toggleFavorite(String uid, String recipeId, bool isFavorite) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('recipes')
        .doc(recipeId)
        .update({'isFavorite': isFavorite});
  }
}
