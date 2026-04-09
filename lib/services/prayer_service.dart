import '../models/prayer_request.dart';
import 'supabase_service.dart';
import 'package:uuid/uuid.dart';

class PrayerService {
  static final PrayerService _instance = PrayerService._internal();
  factory PrayerService() => _instance;
  PrayerService._internal();

  final _supabase = SupabaseService();
  final _uuid = const Uuid();

  Future<List<PrayerRequest>> getAllPrayers() async {
    try {
      final data = await _supabase.query(
        'prayer_requests',
        orderBy: 'date',
        ascending: false,
      );
      return data.map((json) => PrayerRequest.fromSupabase(json)).toList();
    } catch (e) {
      print('❌ Failed to fetch prayers: $e');
      return [];
    }
  }

  Future<void> addPrayer(PrayerRequest prayer) async {
    try {
      final prayerData = prayer.toSupabase();
      prayerData['id'] = _uuid.v4();
      await _supabase.insert('prayer_requests', prayerData);
      print('✅ Prayer added: ${prayer.title}');
    } catch (e) {
      print('❌ Failed to add prayer: $e');
      rethrow;
    }
  }

  Future<void> updatePrayer(PrayerRequest prayer) async {
    try {
      await _supabase.update('prayer_requests', prayer.id, prayer.toSupabase());
      print('✅ Prayer updated');
    } catch (e) {
      print('❌ Failed to update prayer: $e');
      rethrow;
    }
  }

  Future<List<PrayerRequest>> getPrayersByStatus(String status) async {
    try {
      final data = await _supabase.query(
        'prayer_requests',
        column: 'status',
        value: status,
      );
      return data.map((json) => PrayerRequest.fromSupabase(json)).toList();
    } catch (e) {
      print('❌ Failed to fetch prayers by status: $e');
      return [];
    }
  }

  Future<List<PrayerRequest>> getMyPrayers(String userId) async {
    try {
      final data = await _supabase.query(
        'prayer_requests', column: 'user_id', value: userId,
        orderBy: 'date', ascending: false,
      );
      return data.map((json) => PrayerRequest.fromSupabase(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<PrayerRequest>> getAllPrayersForPrayerWarriors() async {
    try {
      final data = await _supabase.query(
        'prayer_requests', column: 'private', value: false,
        orderBy: 'date', ascending: false,
      );
      return data.map((json) => PrayerRequest.fromSupabase(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<PrayerRequest>> getTestimonies() async {
    return await getPrayersByStatus('Answered');
  }

  Future<void> markAsAnswered(String id) async {
    try {
      await _supabase.update('prayer_requests', id, {
        'status': 'Answered',
        'answered_date': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('❌ Failed to mark as answered: $e');
      rethrow;
    }
  }

  Future<void> deletePrayer(String id) async {
    try {
      await _supabase.delete('prayer_requests', id);
    } catch (e) {
      print('❌ Failed to delete prayer: $e');
      rethrow;
    }
  }
}
