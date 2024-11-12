import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jobify/repositories/notification_repository.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository notificationRepository;

  NotificationBloc({required this.notificationRepository})
      : super(NotificationInitial()) {
    on<FetchNotificationsEvent>(_onFetchNotifications);
  }

  Future<void> _onFetchNotifications(
    FetchNotificationsEvent event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading());
    try {
      final notifications = await notificationRepository
          .fetchNotificationsByCategory(event.subCategory);

      if (notifications.isEmpty) {
        emit(NotificationError('No notifications found for this category.'));
      } else {
        emit(NotificationLoaded(notifications: notifications));
      }
    } catch (e) {
      emit(NotificationError('Failed to fetch notifications: $e'));
    }
  }
}
