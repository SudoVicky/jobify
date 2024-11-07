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
