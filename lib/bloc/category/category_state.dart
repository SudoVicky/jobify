import 'package:equatable/equatable.dart';

abstract class CategoryState extends Equatable {
  @override
  List<Object?> get props => [];
}

class CategoryInitial extends CategoryState {}

class CategoryLoading extends CategoryState {}

class PreferencesLoaded extends CategoryState {
  final Map<String, Map<String, bool>> selectedCategories;

  PreferencesLoaded({required this.selectedCategories});

  @override
  List<Object?> get props => [selectedCategories];
}

class UnselectedCategoriesLoaded extends CategoryState {
  final List<MapEntry<String, List<String>>> unselectedCategories;

  UnselectedCategoriesLoaded({required this.unselectedCategories});
}

class TrueSelectedLoaded extends CategoryState {
  final Map<String, List<String>> filteredCategories;

  TrueSelectedLoaded({required this.filteredCategories});
}

class CategoryError extends CategoryState {
  final String message;

  CategoryError(this.message);

  @override
  List<Object?> get props => [message];
}
