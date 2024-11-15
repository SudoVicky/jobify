import 'package:equatable/equatable.dart';

abstract class CategoryEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchPreferencesEvent extends CategoryEvent {
  @override
  List<Object?> get props => [];
}

class UpdatePreferenceEvent extends CategoryEvent {
  final String categoryName;
  final String fieldName;
  final bool newValue;

  UpdatePreferenceEvent({
    required this.categoryName,
    required this.fieldName,
    required this.newValue,
  });

  @override
  List<Object> get props => [categoryName, fieldName, newValue];
}

class FetchUnselectedCategoriesEvent extends CategoryEvent {}

class DeleteCategoryEvent extends CategoryEvent {
  final String categoryName;

  DeleteCategoryEvent({
    required this.categoryName,
  });
  @override
  List<Object?> get props => [categoryName];
}

class AddCategoryEvent extends CategoryEvent {
  final String categoryName;

  AddCategoryEvent({required this.categoryName});

  @override
  List<Object?> get props => [categoryName];
}

class FetchTrueSelectedEvent extends CategoryEvent {}
