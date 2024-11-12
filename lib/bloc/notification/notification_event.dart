import 'package:equatable/equatable.dart';

abstract class NotificationEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchNotificationsEvent extends NotificationEvent {
  final String subCategory;

  FetchNotificationsEvent({required this.subCategory});
  @override
  List<Object?> get props => [subCategory];
}
