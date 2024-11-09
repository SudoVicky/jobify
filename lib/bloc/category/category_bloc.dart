import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jobify/repositories/auth_repository.dart';
import 'package:jobify/repositories/category_repository.dart';
import 'category_event.dart';
import 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final AuthRepository authRepository;
  final CategoryRepository categoryRepository;

  CategoryBloc({required this.authRepository, required this.categoryRepository})
      : super(CategoryInitial()) {
    on<FetchPreferencesEvent>(_onFetchPreferencesEvent);
    on<UpdatePreferenceEvent>(_onUpdatePreferenceEvent);
    on<FetchUnselectedCategoriesEvent>(_onFetchUnselectedCategories);
    on<AddCategoryEvent>(_onAddCategoryEvent);
  }

  // Event handler for fetching preferences
  Future<void> _onFetchPreferencesEvent(
    FetchPreferencesEvent event,
    Emitter<CategoryState> emit,
  ) async {
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
      final currentUser = authRepository.getCurrentUser();
      if (currentUser != null) {
        final docRef = authRepository.firestore
            .collection('userPreferences')
            .doc(currentUser.uid)
            .collection('selectedCategories')
            .doc(event.categoryName);

        await docRef.update({event.fieldName: event.newValue});

        // Dispatch FetchPreferencesEvent to reload data from Firestore
        add(FetchPreferencesEvent());
      }
    } catch (e) {
      emit(CategoryError('Failed to update preference: $e'));
    }
  }

  Future<void> _onFetchUnselectedCategories(
      FetchUnselectedCategoriesEvent event, Emitter<CategoryState> emit) async {
    try {
      // Get the current user
      final currentUser = authRepository.getCurrentUser();
      if (currentUser != null) {
        // Fetch selected categories for the current user
        final selectedCategories =
            await categoryRepository.fetchSelectedCategories(currentUser.uid);

        // Fetch all available categories and their subcategories
        final allCategories = await categoryRepository.fetchAllCategories();

        // Filter out the selected categories from all available categories
        // Only keep categories that are not selected
        final unselectedCategories = allCategories.entries
            .where((entry) => !selectedCategories
                .contains(entry.key)) // Only categories not in selected list
            .map((entry) =>
                MapEntry(entry.key, entry.value)) // Convert to a MapEntry
            .toList();

        // Emit the unselected categories state
        emit(UnselectedCategoriesLoaded(
            unselectedCategories: unselectedCategories));
      } else {
        // Emit error if the user is not logged in
        emit(CategoryError('User not logged in.'));
      }
    } catch (e) {
      // Emit error state if any exception occurs
      emit(CategoryError(
          'Failed to fetch unselected categories: ${e.toString()}'));
    }
  }

  // When adding a category, after successful addition, fetch updated preferences
  Future<void> _onAddCategoryEvent(
      AddCategoryEvent event, Emitter<CategoryState> emit) async {
    try {
      // Add the category to Firebase
      final currentUser = authRepository.getCurrentUser();
      if (currentUser != null) {
        await categoryRepository.addCategoryToPreferences(
          userId: currentUser.uid, // Pass the user ID here
          categoryName: event.categoryName,
        );
      } else {
        emit(CategoryError('User not logged in.'));
      }

      // After adding, fetch the updated preferences
      emit(PreferencesLoading());
      add(FetchPreferencesEvent());
    } catch (e) {
      emit(CategoryError(e.toString())); // Emit error if something goes wrong
    }
  }
}
