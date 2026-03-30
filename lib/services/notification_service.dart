import '../models/app_notification.dart';
import 'supabase_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final _supabase = SupabaseService();

  Future<List<AppNotification>> getNotificationsForUser(String userId) async {
    try {
      final data = await _supabase.query(
        'notifications',
        column: 'user_id',
        value: userId,
        orderBy: 'date',
        ascending: false,
      );
      return data.map((json) => AppNotification.fromSupabase(json)).toList();
    } catch (e) {
      print('❌ Failed to fetch notifications: $e');
      return [];
    }
  }

  Future<int> getUnreadCount(String userId) async {
    try {
      final notifications = await getNotificationsForUser(userId);
      return notifications.where((n) => !n.read).length;
    } catch (e) {
      print('❌ Failed to get unread count: $e');
      return 0;
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _supabase.update('notifications', notificationId, {'read': true});
      print('✅ Notification marked as read');
    } catch (e) {
      print('❌ Failed to mark notification as read: $e');
    }
  }
}
