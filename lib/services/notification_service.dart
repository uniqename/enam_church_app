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

  Future<List<AppNotification>> getAllNotifications() async {
    try {
      final data = await _supabase.getAll('notifications');
      return data.map((json) => AppNotification.fromSupabase(json)).toList();
    } catch (e) {
      print('❌ Failed to fetch all notifications: $e');
      return [];
    }
  }

  Future<void> updateNotification(AppNotification notification) async {
    try {
      await _supabase.update('notifications', notification.id, {'read': notification.read});
    } catch (e) {
      print('❌ Failed to update notification: $e');
    }
  }

  Future<void> markAllAsRead([String? userId]) async {
    try {
      if (userId == null) return;
      final notifications = await getNotificationsForUser(userId);
      for (final n in notifications.where((n) => !n.read)) {
        await markAsRead(n.id);
      }
    } catch (e) {
      print('❌ Failed to mark all as read: $e');
    }
  }
}
