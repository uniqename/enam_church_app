import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/video_content.dart';
import 'supabase_service.dart';

class VideoService {
  static final VideoService _instance = VideoService._internal();
  factory VideoService() => _instance;
  VideoService._internal();

  final _supabase = SupabaseService();
  final _uuid = const Uuid();

  static const String _localVideosKey = 'local_videos';

  Future<List<VideoContent>> _getLocalVideos() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_localVideosKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => VideoContent.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> _saveLocalVideos(List<VideoContent> videos) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _localVideosKey,
      jsonEncode(videos.map((v) => v.toJson()).toList()),
    );
  }

  Future<List<VideoContent>> getAllVideos() async {
    // Always load local first so we always have something to show
    final localVideos = await _getLocalVideos();

    if (SupabaseService.isConfigured) {
      try {
        final data = await _supabase.query(
          'videos',
          orderBy: 'uploaded_at',
          ascending: false,
        );
        if (data.isNotEmpty) {
          final supabaseVideos =
              data.map((json) => VideoContent.fromJson(json)).toList();
          // Merge: Supabase wins for matching IDs, keep local-only items
          final supabaseIds = supabaseVideos.map((v) => v.id).toSet();
          final localOnly =
              localVideos.where((v) => !supabaseIds.contains(v.id)).toList();
          return [...supabaseVideos, ...localOnly];
        }
      } catch (_) {
        // Supabase unavailable — silently use local data
      }
    }
    return localVideos;
  }

  Future<List<VideoContent>> getVideosByAudience(String audience) async {
    final all = await getAllVideos();
    if (audience == 'all') return all;
    return all
        .where((v) => v.audience == audience || v.audience == 'all')
        .toList();
  }

  Future<void> addVideo(VideoContent video) async {
    final withId = VideoContent(
      id: _uuid.v4(),
      title: video.title,
      youtubeUrl: video.youtubeUrl,
      description: video.description,
      audience: video.audience,
      category: video.category,
      uploadedAt: video.uploadedAt,
      uploadedBy: video.uploadedBy,
    );

    // Always save locally first — guarantees the video is never lost
    final videos = await _getLocalVideos();
    videos.insert(0, withId);
    await _saveLocalVideos(videos);

    // Then try to sync to Supabase in the background (silently)
    if (SupabaseService.isConfigured) {
      try {
        await _supabase.insert('videos', withId.toJson());
      } catch (_) {
        // Supabase sync failed — video is safely stored locally
      }
    }
  }

  Future<void> deleteVideo(String id) async {
    // Remove from local storage
    final videos = await _getLocalVideos();
    videos.removeWhere((v) => v.id == id);
    await _saveLocalVideos(videos);

    // Also try to delete from Supabase (silently)
    if (SupabaseService.isConfigured) {
      try {
        await _supabase.delete('videos', id);
      } catch (_) {
        // Supabase delete failed — local copy already removed
      }
    }
  }
}
