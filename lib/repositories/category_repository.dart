import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryRepository {
  final FirebaseFirestore _firestore;

  CategoryRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<Map<String, Map<String, bool>>> fetchAllPreferences(String uid) async {
    try {
      final snapshot = await _firestore
          .collection('userPreferences') // userPreferences collection
          .doc(uid) // Document ID is user UID
          .collection('selectedCategories') // selectedCategories sub-collection
          .get();

      // Map the fetched data to a format suitable for the UI
      return {
        for (var doc in snapshot.docs)
          doc.id: doc.data().map((key, value) => MapEntry(key, value as bool)),
      };
    } catch (e) {
      throw Exception('Error fetching selected categories: $e');
    }
  }

  // Fetch selected categories for the current user
  Future<List<String>> fetchSelectedCategories(String uid) async {
    try {
      final snapshot = await _firestore
          .collection('userPreferences') // userPreferences collection
          .doc(uid) // Document ID is user UID
          .collection('selectedCategories') // selectedCategories sub-collection
          .get();

      // If no categories are selected, return an empty list
      if (snapshot.docs.isEmpty) {
        return [];
      }

      // Return the category names (document IDs)
      return snapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      throw Exception('Error fetching selected categories: $e');
    }
  }

  // Fetch all available categories from Firestore
  Future<Map<String, List<String>>> fetchAllCategories() async {
    try {
      final snapshot = await _firestore.collection('categories').get();
      final categories = <String, List<String>>{};
      for (var doc in snapshot.docs) {
        categories[doc.id] = List<String>.from(doc['subCategories']);
      }
      return categories;
    } catch (e) {
      throw Exception('Error fetching all categories: $e');
    }
  }

  Future<void> addCategoryToPreferences({
    required String userId,
    required String categoryName,
  }) async {
    try {
      // Get the subcategories for the selected category
      final categoriesSnapshot =
          await _firestore.collection('categories').doc(categoryName).get();

      if (!categoriesSnapshot.exists) {
        throw Exception('Category not found in Firestore.');
      }

      final subcategories =
          List<String>.from(categoriesSnapshot['subCategories']);

      // Prepare the data structure with subcategories set to false initially
      final subcategoryData = {
        for (var subcategory in subcategories) subcategory: false
      };

      // Add the category and its subcategories to the user's selected categories
      await _firestore
          .collection('userPreferences')
          .doc(userId)
          .collection('selectedCategories')
          .doc(categoryName) // Document ID is the category name
          .set(subcategoryData);
    } catch (e) {
      throw Exception('Error adding category to preferences: $e');
    }
  }

  Future<void> deleteCategory(String userId, String categoryName) async {
    try {
      // Reference to the selected category of the authenticated user
      final categoryRef = _firestore
          .collection('userPreferences')
          .doc(userId) // User's ID to make it specific
          .collection('selectedCategories')
          .doc(categoryName); // Category name as document ID
      await categoryRef.delete();

      // Delete the category document from Firestore
    } catch (e) {
      throw Exception('Error deleting category: $e');
    }
  }

  Future<Map<String, List<String>>> fetchTrueSelectedCategories(
      String uid) async {
    try {
      final snapshot = await _firestore
          .collection('userPreferences') // userPreferences collection
          .doc(uid) // Document ID is user UID
          .collection('selectedCategories') // selectedCategories sub-collection
          .get();

      // Map the fetched data to a format suitable for the UI
      return {
        for (var doc in snapshot.docs)
          doc.id: [
            // Only include subcategory names where the value is true
            for (var entry in doc.data().entries)
              if (entry.value == true) entry.key,
          ],
      };
    } catch (e) {
      throw Exception('Error fetching selected categories: $e');
    }
  }
}
