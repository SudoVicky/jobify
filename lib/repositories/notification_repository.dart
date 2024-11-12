// Import intl package for date formatting
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch notifications for a given category (e.g., Navy)
  Future<List<Map<String, String>>> fetchNotificationsByCategory(
      String category) async {
    try {
      final querySnapshot = await _firestore
          .collection('jobNotifications')
          .where('from', isEqualTo: category) // Filter by category
          .get();

      // Map each document to a structured format
      List<Map<String, String>> notifications = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'from': data['from'] as String,
          'message': data['message'] as String,
          'postDate': (data['postDate'] as Timestamp).toDate().toString(),
        };
      }).toList();

      // Sort notifications by postDate (timestamp)
      notifications.sort((a, b) {
        DateTime dateA = DateTime.parse(a['postDate']!);
        DateTime dateB = DateTime.parse(b['postDate']!);
        return dateB.compareTo(dateA); // Sorting in descending order
      });
      return notifications;
    } catch (e) {
      throw Exception('Error fetching notifications: $e');
    }
  }
}
