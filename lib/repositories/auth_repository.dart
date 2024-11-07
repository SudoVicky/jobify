import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthRepository({FirebaseAuth? firebaseAuth, FirebaseFirestore? firestore})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  FirebaseFirestore get firestore => _firestore;
  // Sign in with email and password
  Future<User?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential =
          await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  // Register with email and password
  Future<User?> registerWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCredential.user;

      // After registering, create a user preferences document
      if (user != null) {
        await createUserPreferences(user.uid);
      }
      return user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<void> createUserPreferences(String uid) async {
    try {
      final userPreferencesDocRef =
          FirebaseFirestore.instance.collection('userPreferences').doc(uid);

      // Check if the user document already exists
      final userDocSnapshot = await userPreferencesDocRef.get();
      if (!userDocSnapshot.exists) {
        // Create the user document if it does not exist, without adding any data
        await userPreferencesDocRef.set({});
        print("UserPreferences document created for uid: $uid");
      }

      // Ensures `selectedCategories` collection is ready without adding any document
      print("selectedCategories collection available for user: $uid");
    } on FirebaseException catch (e) {
      print("Firebase error during document creation: ${e.message}");
    } catch (e) {
      print("Unexpected error during document creation: $e");
    }
  }

  // Sign out the current user
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  // Check if a user is currently signed in
  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }
}
