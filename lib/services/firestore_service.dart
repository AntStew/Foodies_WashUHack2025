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

  Stream<UserModel?> getUserProfileStream(String uid) {
    return _db.collection('users').doc(uid).snapshots()
        .timeout(
          const Duration(seconds: 30),
          onTimeout: (eventSink) {
            AppLogger.error('User profile request timed out');
            eventSink.addError('User profile request timed out');
            eventSink.close();
          },
        )
        .map((doc) {
          try {
            if (doc.exists) {
              return UserModel.fromMap(doc.data()!);
            }
            return null;
          } catch (e) {
            AppLogger.error('Error processing user profile data: $e');
            return null;
          }
        })
        .handleError((error) {
          AppLogger.error('User profile stream error: $error');
          return null;
        });
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
      },
    });
  }

  // Fridge Item Operations
  Stream<List<FridgeItem>> getFridgeItems(String uid) {
    try {
      // Check if uid is valid
      if (uid.isEmpty) {
        AppLogger.error('Cannot get fridge items: User ID is empty');
        return Stream.value(<FridgeItem>[]);
      }

      return _db
          .collection('users')
          .doc(uid)
          .collection('fridgeItems')
          .limit(100)
          .snapshots()
          .timeout(
            const Duration(seconds: 30),
            onTimeout: (eventSink) {
              AppLogger.error('Fridge items stream timeout after 30 seconds');
              eventSink.addError('Fridge items stream timeout');
              eventSink.close();
            },
          )
          .map(_processFridgeItemsSnapshot)
          .handleError(_handleFridgeItemsError);
    } catch (e) {
      AppLogger.error('Error creating fridge items stream: $e');
      return Stream.value(<FridgeItem>[]);
    }
  }

  List<FridgeItem> _processFridgeItemsSnapshot(QuerySnapshot snapshot) {
    try {
      final items = <FridgeItem>[];
      for (final doc in snapshot.docs) {
        try {
          items.add(FridgeItem.fromMap(doc.id, doc.data() as Map<String, dynamic>));
        } catch (e) {
          AppLogger.error('Error processing fridge item ${doc.id}: $e');
        }
      }
      items.sort((a, b) => b.addedDate.compareTo(a.addedDate));
      return items;
    } catch (e) {
      AppLogger.error('Error processing fridge items snapshot: $e');
      return <FridgeItem>[];
    }
  }

  List<FridgeItem> _handleFridgeItemsError(dynamic error) {
    if (error.toString().contains('TimeoutException')) {
      AppLogger.error('Fridge items stream timeout: Network connection may be slow or unavailable. Retrying...');
    } else if (error.toString().contains('permission-denied')) {
      AppLogger.error('Fridge items stream error: Permission denied. User may not be authenticated.');
    } else if (error.toString().contains('unavailable')) {
      AppLogger.error('Fridge items stream error: Firestore service is temporarily unavailable.');
    } else {
      AppLogger.error('Fridge items stream error: $error');
    }
    return <FridgeItem>[];
  }

  Future<void> addFridgeItem(String uid, FridgeItem item) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('fridgeItems')
        .add(item.toMap());
  }

  Future<void> updateFridgeItem(
    String uid,
    String itemId,
    Map<String, dynamic> data,
  ) async {
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
    try {
      return _db
          .collection('users')
          .doc(uid)
          .collection('recipes')
          .limit(50)
          .snapshots()
          .timeout(const Duration(seconds: 30))
          .map(_processSavedRecipesSnapshot)
          .handleError(_handleSavedRecipesError);
    } catch (e) {
      AppLogger.error('Error creating saved recipes stream: $e');
      return Stream.value(<Recipe>[]);
    }
  }

  List<Recipe> _processSavedRecipesSnapshot(QuerySnapshot snapshot) {
    try {
      final recipes = <Recipe>[];
      for (final doc in snapshot.docs) {
        try {
          recipes.add(Recipe.fromMap(doc.id, doc.data() as Map<String, dynamic>));
        } catch (e) {
          AppLogger.error('Error processing saved recipe ${doc.id}: $e');
        }
      }
      recipes.sort((a, b) => b.savedAt.compareTo(a.savedAt));
      return recipes;
    } catch (e) {
      AppLogger.error('Error processing saved recipes snapshot: $e');
      return <Recipe>[];
    }
  }

  List<Recipe> _handleSavedRecipesError(dynamic error) {
    AppLogger.error('Saved recipes stream error: $error');
    return <Recipe>[];
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

  Future<void> toggleFavorite(
    String uid,
    String recipeId,
    bool isFavorite,
  ) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('recipes')
        .doc(recipeId)
        .update({'isFavorite': isFavorite});
  }

  // Shopping List Operations
  Stream<List<ShoppingListItem>> getShoppingList(String uid) {
    try {
      return _db
          .collection('users')
          .doc(uid)
          .collection('shoppingList')
          .limit(200)
          .snapshots()
          .timeout(const Duration(seconds: 30))
          .map(_processShoppingListSnapshot)
          .handleError(_handleShoppingListError);
    } catch (e) {
      AppLogger.error('Error creating shopping list stream: $e');
      return Stream.value(<ShoppingListItem>[]);
    }
  }

  List<ShoppingListItem> _processShoppingListSnapshot(QuerySnapshot snapshot) {
    try {
      final items = <ShoppingListItem>[];
      for (final doc in snapshot.docs) {
        try {
          items.add(ShoppingListItem.fromMap(doc.id, doc.data() as Map<String, dynamic>));
        } catch (e) {
          AppLogger.error('Error processing shopping list item ${doc.id}: $e');
        }
      }
      items.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      return items;
    } catch (e) {
      AppLogger.error('Error processing shopping list snapshot: $e');
      return <ShoppingListItem>[];
    }
  }

  List<ShoppingListItem> _handleShoppingListError(dynamic error) {
    AppLogger.error('Shopping list stream error: $error');
    return <ShoppingListItem>[];
  }

  Future<void> addShoppingListItem(String uid, ShoppingListItem item) async {
    try {
      AppLogger.info('Adding shopping list item for user: $uid');
      AppLogger.debug(
        'Item: ${item.name}, Category: ${item.category}, Quantity: ${item.quantity}',
      );

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

  Future<void> addMultipleShoppingListItems(
    String uid,
    List<ShoppingListItem> items,
  ) async {
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

  Future<void> toggleShoppingListItem(
    String uid,
    String itemId,
    bool isChecked,
  ) async {
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
        .snapshots()
        .timeout(
          const Duration(seconds: 5),
          onTimeout: (eventSink) {
            eventSink.addError('Suggested stores request timed out');
            eventSink.close();
          },
        )
        .map(
          (snapshot) {
            try {
              return snapshot.docs
                  .map((doc) => SuggestedStore.fromMap(doc.id, doc.data()))
                  .toList()
                  ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
            } catch (e) {
              AppLogger.error('Error processing suggested stores data: $e');
              return <SuggestedStore>[];
            }
          },
        )
        .handleError((error) {
          AppLogger.error('Suggested stores stream error: $error');
          return <SuggestedStore>[];
        });
  }

  Future<void> saveSuggestedStores(
    String uid,
    List<Map<String, dynamic>> stores,
  ) async {
    try {
      AppLogger.info('Saving ${stores.length} suggested stores for user: $uid');

      // Check authentication state first
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        AppLogger.error('No authenticated user found');
        throw Exception('User not authenticated. Please sign in again.');
      }

      if (currentUser.uid != uid) {
        AppLogger.error(
          'UID mismatch: current user ${currentUser.uid} vs requested $uid',
        );
        throw Exception('User ID mismatch. Please sign in again.');
      }

      AppLogger.info('User authentication verified: ${currentUser.uid}');

      // Ensure user document exists
      final userDoc = await _db.collection('users').doc(uid).get();
      if (!userDoc.exists) {
        AppLogger.warning(
          'User document does not exist for uid: $uid, creating it...',
        );
        // Create a basic user document
        await _db.collection('users').doc(uid).set({
          'uid': uid,
          'email': currentUser.email ?? '',
          'displayName': currentUser.displayName ?? '',
          'createdAt': FieldValue.serverTimestamp(),
        });
        AppLogger.info('User document created successfully');
      }

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
    try {
      AppLogger.info('Clearing suggested stores for user: $uid');

      // Check if user document exists first
      final userDoc = await _db.collection('users').doc(uid).get();
      if (!userDoc.exists) {
        AppLogger.info('User document does not exist, no stores to clear');
        return;
      }

      final batch = _db.batch();
      final stores = await _db
          .collection('users')
          .doc(uid)
          .collection('suggestedStores')
          .get();

      AppLogger.info('Found ${stores.docs.length} existing stores to clear');

      for (var doc in stores.docs) {
        batch.delete(doc.reference);
      }

      if (stores.docs.isNotEmpty) {
        await batch.commit();
      }
      AppLogger.info('Suggested stores cleared successfully');
    } catch (e) {
      AppLogger.error('Error clearing suggested stores', e);
      rethrow;
    }
  }
}
