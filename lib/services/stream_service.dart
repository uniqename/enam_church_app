import '../models/live_stream.dart';
import 'supabase_service.dart';
import 'package:uuid/uuid.dart';

class StreamService {
  static final StreamService _instance = StreamService._internal();
  factory StreamService() => _instance;
  StreamService._internal();

  final _supabase = SupabaseService();
  final _uuid = const Uuid();

  Future<List<LiveStream>> getAllStreams() async {
    try {
      final data = await _supabase.query(
        'live_streams',
        orderBy: 'date',
        ascending: false,
      );
      return data.map((json) => LiveStream.fromSupabase(json)).toList();
    } catch (e) {
      print('❌ Failed to fetch streams: $e');
      return [];
    }
  }

  Future<void> addStream(LiveStream stream) async {
    try {
      final streamData = stream.toSupabase();
      streamData['id'] = _uuid.v4();
      await _supabase.insert('live_streams', streamData);
      print('✅ Stream added');
    } catch (e) {
      print('❌ Failed to add stream: $e');
      rethrow;
    }
  }

  Future<List<LiveStream>> getLiveStreams() async {
    try {
      final data = await _supabase.query(
        'live_streams',
        column: 'status',
        value: 'Live',
      );
      return data.map((json) => LiveStream.fromSupabase(json)).toList();
    } catch (e) {
      print('❌ Failed to fetch live streams: $e');
      return [];
    }
  }
}
