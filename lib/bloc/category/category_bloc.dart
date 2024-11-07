import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jobify/repositories/auth_repository.dart';
import 'category_event.dart';
import 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final AuthRepository authRepository;

  CategoryBloc({required this.authRepository}) : super(CategoryInitial()) {
    on<FetchPreferencesEvent>(_onFetchPreferencesEvent);
    on<UpdatePreferenceEvent>(_onUpdatePreferenceEvent);
  }

  // Event handler for fetching preferences
  Future<void> _onFetchPreferencesEvent(
      FetchPreferencesEvent event, Emitter<CategoryState> emit) async {
    try {
      emit(PreferencesLoading()); // Emit loading state before fetching
      print("Fetching preferences...");

      final currentUser = authRepository.getCurrentUser();
      if (currentUser != null) {
        print("Current user UID: ${currentUser.uid}");

        // Fetch user preferences from Firestore
        final userPreferencesRef = authRepository.firestore
            .collection('userPreferences')
            .doc(currentUser.uid);
        final selectedCategoriesRef =
            userPreferencesRef.collection('selectedCategories');

        // Fetch the selected categories from Firestore
        final snapshot = await selectedCategoriesRef.get();

        print("Fetched ${snapshot.docs.length} documents from Firestore.");

        if (snapshot.docs.isEmpty) {
          print("No preferences found for this user.");
          emit(CategoryError('Add your preferences!'));
          return;
        }

        // Debug: Print out each document ID and its data
        for (var doc in snapshot.docs) {
          print("Document ID: ${doc.id}, Data: ${doc.data()}");

          // You can inspect the data format of each category
          doc.data().forEach((key, value) {
            print("Category: $key, Fields: $value");
          });
        }

        // Map the fetched data to a format we can use in the UI
        final selectedCategories = {
          for (var doc in snapshot.docs)
            doc.id:
                doc.data().map((key, value) => MapEntry(key, value as bool)),
        };

        print("Mapped selected categories: $selectedCategories");

        emit(PreferencesLoaded(selectedCategories: selectedCategories));
      } else {
        print("User not logged in.");
        emit(CategoryError('User not logged in.'));
      }
    } catch (e) {
      print("Error while fetching preferences: $e");
      emit(CategoryError('Failed to fetch preferences: $e'));
    }
  }

  void _onUpdatePreferenceEvent(
    UpdatePreferenceEvent event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      // Update Firestore with the new value
      final currentUser = authRepository.getCurrentUser();
      if (currentUser != null) {
        final docRef = authRepository.firestore
            .collection('userPreferences')
            .doc(currentUser.uid)
            .collection('selectedCategories')
            .doc(event.categoryName);

        await docRef.update({event.fieldName: event.newValue});
      }
    } catch (e) {
      emit(CategoryError('Failed to update preference: $e'));
    }
  }
}
