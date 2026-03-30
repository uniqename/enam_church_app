import '../models/announcement.dart';
import 'supabase_service.dart';
import 'package:uuid/uuid.dart';

class AnnouncementService {
  static final AnnouncementService _instance = AnnouncementService._internal();
  factory AnnouncementService() => _instance;
  AnnouncementService._internal();

  final _supabase = SupabaseService();
  final _uuid = const Uuid();

  Future<List<Announcement>> getAllAnnouncements() async {
    try {
      final data = await _supabase.query(
        'announcements',
        orderBy: 'date',
        ascending: false,
      );
      return data.map((json) => Announcement.fromSupabase(json)).toList();
    } catch (e) {
      print('❌ Failed to fetch announcements: $e');
      return [];
    }
  }

  Future<void> addAnnouncement(Announcement announcement) async {
    try {
      final announcementData = announcement.toSupabase();
      announcementData['id'] = _uuid.v4();
      await _supabase.insert('announcements', announcementData);
      print('✅ Announcement added');
    } catch (e) {
      print('❌ Failed to add announcement: $e');
      rethrow;
    }
  }

  Future<void> updateAnnouncement(Announcement announcement) async {
    try {
      await _supabase.update('announcements', announcement.id, announcement.toSupabase());
      print('✅ Announcement updated');
    } catch (e) {
      print('❌ Failed to update announcement: $e');
      rethrow;
    }
  }

  Future<void> deleteAnnouncement(String id) async {
    try {
      await _supabase.delete('announcements', id);
      print('✅ Announcement deleted');
    } catch (e) {
      print('❌ Failed to delete announcement: $e');
      rethrow;
    }
  }
}
