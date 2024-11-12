import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jobify/bloc/notification/notification_bloc.dart';
import 'package:jobify/bloc/notification/notification_event.dart';
import 'package:jobify/bloc/notification/notification_state.dart';
import 'package:intl/intl.dart'; // Import for date formatting

class DetailedNotificationPage extends StatelessWidget {
  final String subCategory;

  const DetailedNotificationPage({super.key, required this.subCategory});

  @override
  Widget build(BuildContext context) {
    // Triggering the FetchNotificationsEvent
    context
        .read<NotificationBloc>()
        .add(FetchNotificationsEvent(subCategory: subCategory));

    return Scaffold(
      appBar: AppBar(
        title: Text('$subCategory'),
      ),
      body: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          if (state is NotificationLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is NotificationError) {
            return Center(child: Text(state.message));
          } else if (state is NotificationLoaded) {
            return ListView.builder(
              itemCount: state.notifications.length,
              itemBuilder: (context, index) {
                final notification = state.notifications[index];

                // Convert postDate to a DateTime object and format it as DD-MM-YYYY
                final dateTime =
                    DateTime.parse(notification['postDate']!).toLocal();
                final formattedDate = DateFormat('dd-MM-yyyy').format(dateTime);

                return ListTile(
                  // String title =
                  title: Text(formattedDate),
                  subtitle: Text(
                    notification['message']!.length > 50
                        ? '${notification['message']!.substring(0, 50)}...'
                        : notification['message']!,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ), // Display the formatted date
                  onTap: () => _showFullNotificationDialog(
                      context, formattedDate, notification['message']!),
                );
              },
            );
          } else {
            return Center(child: Text('Something went wrong.'));
          }
        },
      ),
    );
  }

  // Helper function to show the full notification in an alert dialog
  void _showFullNotificationDialog(
      BuildContext context, String formattedDate, String fullMessage) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(formattedDate),
          content: Text(fullMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
