import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../models/fridge_item_model.dart';
import '../models/recipe_model.dart';
import '../models/shopping_list_item_model.dart';
import '../models/suggested_store_model.dart';
import '../utils/logger.dart';

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

  // Shopping List Operations
  Stream<List<ShoppingListItem>> getShoppingList(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('shoppingList')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ShoppingListItem.fromMap(doc.id, doc.data()))
            .toList());
  }

  Future<void> addShoppingListItem(String uid, ShoppingListItem item) async {
    try {
      AppLogger.info('Adding shopping list item for user: $uid');
      AppLogger.debug('Item: ${item.name}, Category: ${item.category}, Quantity: ${item.quantity}');

      await _db
          .collection('users')
          .doc(uid)
          .collection('shoppingList')
          .add(item.toMap());

      AppLogger.info('Item added successfully');
    } catch (e) {
      AppLogger.error('Error adding shopping list item', e);
      rethrow;
    }
  }

  Future<void> addMultipleShoppingListItems(String uid, List<ShoppingListItem> items) async {
    final batch = _db.batch();

    for (var item in items) {
      final docRef = _db
          .collection('users')
          .doc(uid)
          .collection('shoppingList')
          .doc();
      batch.set(docRef, item.toMap());
    }

    await batch.commit();
  }

  Future<void> toggleShoppingListItem(String uid, String itemId, bool isChecked) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('shoppingList')
        .doc(itemId)
        .update({'isChecked': isChecked});
  }

  Future<void> deleteShoppingListItem(String uid, String itemId) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('shoppingList')
        .doc(itemId)
        .delete();
  }

  Future<void> clearShoppingList(String uid) async {
    final batch = _db.batch();
    final items = await _db
        .collection('users')
        .doc(uid)
        .collection('shoppingList')
        .get();

    for (var doc in items.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  Future<void> clearCheckedItems(String uid) async {
    final batch = _db.batch();
    final items = await _db
        .collection('users')
        .doc(uid)
        .collection('shoppingList')
        .where('isChecked', isEqualTo: true)
        .get();

    for (var doc in items.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  // ===== Suggested Stores Methods =====

  Stream<List<SuggestedStore>> getSuggestedStores(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('suggestedStores')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SuggestedStore.fromMap(doc.id, doc.data()))
            .toList());
  }

  Future<void> saveSuggestedStores(String uid, List<Map<String, dynamic>> stores) async {
    try {
      AppLogger.info('Saving ${stores.length} suggested stores for user: $uid');

      // Clear existing stores first
      await clearSuggestedStores(uid);

      // Add new stores
      final batch = _db.batch();
      final storesCollection = _db
          .collection('users')
          .doc(uid)
          .collection('suggestedStores');

      for (var storeData in stores) {
        final docRef = storesCollection.doc();
        batch.set(docRef, {
          'name': storeData['name'] ?? '',
          'reason': storeData['reason'] ?? '',
          'categories': storeData['categories'] ?? [],
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
      AppLogger.info('Suggested stores saved successfully');
    } catch (e) {
      AppLogger.error('Error saving suggested stores', e);
      rethrow;
    }
  }

  Future<void> clearSuggestedStores(String uid) async {
    final batch = _db.batch();
    final stores = await _db
        .collection('users')
        .doc(uid)
        .collection('suggestedStores')
        .get();

    for (var doc in stores.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }
}
