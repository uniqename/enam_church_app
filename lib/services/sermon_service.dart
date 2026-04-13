import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/sermon.dart';
import 'supabase_service.dart';

class SermonService {
  static const _kSermonsKey = 'local_sermons_cache';
  final _supabase = SupabaseService();

  // ── Read ──────────────────────────────────────────────────────────────────
  Future<List<Sermon>> getAllSermons() async {
    List<Sermon> supabaseSermons = [];
    if (SupabaseService.isConfigured) {
      try {
        final data = await _supabase.query('sermons', orderBy: 'sermon_date', ascending: false);
        supabaseSermons = data.map((j) => Sermon.fromSupabase(j)).toList();
      } catch (e) {
        print('⚠️ Supabase sermons fetch failed: $e');
      }
    }
    // Merge with local cache — local ones not in Supabase still show
    final cached = await _cachedSermons();
    final supabaseIds = supabaseSermons.map((s) => s.id).toSet();
    final localOnly = cached.where((s) => !supabaseIds.contains(s.id)).toList();
    final merged = [...supabaseSermons, ...localOnly];
    merged.sort((a, b) => b.date.compareTo(a.date));
    // Update cache with latest from Supabase
    if (supabaseSermons.isNotEmpty) _cacheSermons(merged);
    return merged;
  }

  // ── Write ─────────────────────────────────────────────────────────────────
  Future<Sermon> addSermon(Sermon sermon) async {
    if (SupabaseService.isConfigured) {
      final data = sermon.toSupabase();
      await _supabase.insert('sermons', data);
    }
    // Also update local cache
    final cached = await _cachedSermons();
    cached.insert(0, sermon);
    await _cacheSermons(cached);
    return sermon;
  }

  Future<void> updateSermon(Sermon sermon) async {
    if (SupabaseService.isConfigured) {
      await _supabase.update('sermons', sermon.id, sermon.toSupabase());
    }
    final cached = await _cachedSermons();
    final idx = cached.indexWhere((s) => s.id == sermon.id);
    if (idx != -1) cached[idx] = sermon;
    await _cacheSermons(cached);
  }

  Future<void> deleteSermon(String id) async {
    if (SupabaseService.isConfigured) {
      await _supabase.delete('sermons', id);
    }
    final cached = await _cachedSermons();
    cached.removeWhere((s) => s.id == id);
    await _cacheSermons(cached);
  }

  // ── Local file helpers (still needed for local audio playback) ────────────
  Future<String> copyFileToSermonStorage(String sourcePath) async {
    final dir = await _sermonsDirectory();
    final fileName = sourcePath.split('/').last;
    final dest = '${dir.path}/$fileName';
    final sourceFile = File(sourcePath);
    if (await sourceFile.exists()) {
      await sourceFile.copy(dest);
    }
    return dest;
  }

  Future<Directory> _sermonsDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory('${appDir.path}/sermons');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  // ── Cache helpers ─────────────────────────────────────────────────────────
  Future<List<Sermon>> _cachedSermons() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_kSermonsKey) ?? [];
    return raw.map((s) => Sermon.fromJson(jsonDecode(s))).toList();
  }

  Future<void> _cacheSermons(List<Sermon> sermons) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _kSermonsKey,
      sermons.map((s) => jsonEncode(s.toJson())).toList(),
    );
  }
}
