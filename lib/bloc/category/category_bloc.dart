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
    on<DeleteCategoryEvent>(_onDeleteCategoryEvent);
    on<FetchTrueSelectedEvent>(_onFetchTrueSelectedEvent);
  }

  Future<void> _onFetchPreferencesEvent(
    FetchPreferencesEvent event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      emit(CategoryLoading()); // Emit loading state before fetching
      print("Fetching preferences...");

      final currentUser = authRepository.getCurrentUser();
      if (currentUser != null) {
        print("Current user UID: ${currentUser.uid}");

        // Fetch the selected categories from the CategoryRepository
        final selectedCategories =
            await categoryRepository.fetchAllPreferences(currentUser.uid);

        if (selectedCategories.isEmpty) {
          print("No preferences found for this user.");
          emit(CategoryError('Add your preferences.'));
          return;
        }

        // Debug: Print the selected categories
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
      emit(CategoryLoading());
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
      emit(CategoryLoading());
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
      add(FetchPreferencesEvent());
    } catch (e) {
      emit(CategoryError(e.toString())); // Emit error if something goes wrong
    }
  }

  Future<void> _onDeleteCategoryEvent(
    DeleteCategoryEvent event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      emit(CategoryLoading());
      final currentUser = authRepository.getCurrentUser();
      if (currentUser != null) {
        // Reference to the category document to be deleted
        await categoryRepository.deleteCategory(
            currentUser.uid, event.categoryName);

        // Fetch updated preferences after deletion
        add(FetchPreferencesEvent());
      } else {
        emit(CategoryError('User not logged in.'));
      }
    } catch (e) {
      emit(CategoryError('Error deleting category: $e'));
    }
  }

  Future<void> _onFetchTrueSelectedEvent(
    FetchTrueSelectedEvent event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      emit(CategoryLoading());
      final currentUser = authRepository.getCurrentUser();
      if (currentUser != null) {
        // Fetch the true selected categories directly
        final selectedCategories = await categoryRepository
            .fetchTrueSelectedCategories(currentUser.uid);

        // If no categories with true subcategories are found, emit an empty state
        if (selectedCategories.isEmpty) {
          emit(CategoryError("Enable notification in preferences"));
        }
        // Check each category if it has no selected subcategories

        // If we have categories with true subcategories, emit them
        emit(TrueSelectedLoaded(filteredCategories: selectedCategories));
      } else {
        emit(CategoryError('User not logged in.'));
      }
    } catch (e) {
      emit(CategoryError('Failed to fetch notifications: $e'));
    }
  }
}
