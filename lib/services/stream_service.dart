import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/live_stream.dart';
import 'supabase_service.dart';

class StreamService {
  static final StreamService _instance = StreamService._internal();
  factory StreamService() => _instance;
  StreamService._internal();

  final _supabase = SupabaseService();
  final _uuid = const Uuid();

  static const _localKey = 'local_streams_v2';

  // ── Demo seeds ─────────────────────────────────────────────────────────────
  static List<LiveStream> get _demoSeeds => [
    LiveStream(
      id: 'seed-yt-sunday',
      title: 'Sunday Service Live',
      date: DateTime.now().add(const Duration(days: 3)),
      time: '9:00 AM',
      status: 'Upcoming',
      viewers: 0,
      category: 'Worship',
      streamUrl: 'https://youtube.com/faithklinik',
      platform: 'youtube',
      platformUrl: 'https://youtube.com/faithklinik',
      description: 'Join us every Sunday for a life-transforming service.',
    ),
    LiveStream(
      id: 'seed-zoom-prayer',
      title: 'Prayer Night',
      date: DateTime.now().add(const Duration(days: 1)),
      time: '8:00 PM',
      status: 'Upcoming',
      viewers: 0,
      category: 'Prayer',
      streamUrl: 'https://zoom.us/j/6193422249',
      platform: 'zoom',
      platformUrl: 'https://zoom.us/j/6193422249',
      description: 'Zoom ID: 619 342 2249 — Come ready to pray!',
    ),
    LiveStream(
      id: 'seed-meet-bible',
      title: 'Bible Study',
      date: DateTime.now().add(const Duration(days: 5)),
      time: '7:00 PM',
      status: 'Upcoming',
      viewers: 0,
      category: 'Teaching',
      streamUrl: 'https://meet.google.com/faithklinik-bible',
      platform: 'google_meet',
      platformUrl: 'https://meet.google.com/faithklinik-bible',
      description: 'Mid-week Bible study via Google Meet.',
    ),
  ];

  // ── CRUD ───────────────────────────────────────────────────────────────────
  Future<List<LiveStream>> getAllStreams() async {
    if (SupabaseService.isConfigured) {
      try {
        final data = await _supabase.query('live_streams', orderBy: 'date', ascending: false);
        if (data.isNotEmpty) return data.map((j) => LiveStream.fromSupabase(j)).toList();
      } catch (_) {}
    }
    return _loadLocal();
  }

  Future<List<LiveStream>> _loadLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_localKey);
    if (raw == null) {
      // First load — save seeds
      final seeds = _demoSeeds;
      await _saveLocal(seeds);
      return seeds;
    }
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((j) => LiveStream.fromSupabase(j as Map<String, dynamic>)).toList();
  }

  Future<void> _saveLocal(List<LiveStream> streams) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localKey, jsonEncode(streams.map((s) => s.toSupabase()).toList()));
  }

  Future<void> addStream(LiveStream stream) async {
    if (SupabaseService.isConfigured) {
      try {
        final data = stream.toSupabase();
        data['id'] = _uuid.v4();
        await _supabase.insert('live_streams', data);
        return;
      } catch (_) {}
    }
    final all = await _loadLocal();
    all.insert(0, stream);
    await _saveLocal(all);
  }

  Future<void> updateStream(LiveStream stream) async {
    if (SupabaseService.isConfigured) {
      try {
        await _supabase.update('live_streams', stream.id, stream.toSupabase());
        return;
      } catch (_) {}
    }
    final all = await _loadLocal();
    final idx = all.indexWhere((s) => s.id == stream.id);
    if (idx >= 0) all[idx] = stream;
    await _saveLocal(all);
  }

  Future<void> deleteStream(String id) async {
    if (SupabaseService.isConfigured) {
      try {
        await _supabase.delete('live_streams', id);
        return;
      } catch (_) {}
    }
    final all = await _loadLocal();
    all.removeWhere((s) => s.id == id);
    await _saveLocal(all);
  }

  Future<void> updateStreamUrl(String id, String url) async {
    final all = await _loadLocal();
    final idx = all.indexWhere((s) => s.id == id);
    if (idx >= 0) {
      final s = all[idx];
      all[idx] = LiveStream(
        id: s.id, title: s.title, date: s.date, time: s.time,
        status: s.status, viewers: s.viewers, category: s.category,
        streamUrl: url, platform: s.platform, platformUrl: url,
        description: s.description,
      );
      await _saveLocal(all);
    }
    if (SupabaseService.isConfigured) {
      try { await _supabase.update('live_streams', id, {'stream_url': url}); } catch (_) {}
    }
  }

  Future<List<LiveStream>> getLiveStreams() async {
    final all = await getAllStreams();
    return all.where((s) => s.status == 'Live').toList();
  }
}
