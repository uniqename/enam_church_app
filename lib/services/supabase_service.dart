import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  SupabaseClient? _client;
  SupabaseClient get client => _client!;

  static bool isConfigured = false;

  Future<void> initialize() async {
    final url = dotenv.env['SUPABASE_URL'] ?? '';
    final anonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

    if (url.isEmpty || anonKey.isEmpty || url == 'https://placeholder.supabase.co') {
      print('⚠️ Supabase not configured — running in demo/local mode');
      isConfigured = false;
      return;
    }

    try {
      await Supabase.initialize(url: url, anonKey: anonKey);
      _client = Supabase.instance.client;
      isConfigured = true;
      print('✅ Supabase initialized');
    } catch (e) {
      print('⚠️ Supabase init failed, running in demo mode: $e');
      isConfigured = false;
    }
  }

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    final response = await _client!.auth.signUp(
      email: email,
      password: password,
      data: {'name': name, 'role': role, 'app': 'faithklinik'},
    );
    if (response.user != null) {
      await _client!.from('users').insert({
        'id': response.user!.id,
        'email': email,
        'name': name,
        'role': role,
        'status': 'active',
      });
    }
    return response;
  }

  Future<AuthResponse> signIn({required String email, required String password}) async {
    final response = await _client!.auth.signInWithPassword(email: email, password: password);
    if (response.user != null) {
      final appTag = response.user!.appMetadata['app'] as String?;
      // Allow: faithklinik, both, or untagged. Block: beacon-only accounts.
      if (appTag == 'beacon') {
        await _client!.auth.signOut();
        throw Exception('This account is not registered for FaithKlinik.');
      }
    }
    return response;
  }

  Future<void> signOut() async {
    await _client?.auth.signOut();
  }

  User? get currentUser => isConfigured ? _client?.auth.currentUser : null;

  Stream<AuthState> get authStateChanges =>
      isConfigured ? _client!.auth.onAuthStateChange : const Stream.empty();

  Future<List<Map<String, dynamic>>> getAll(String table) async {
    if (!isConfigured) return [];
    try {
      final response = await _client!.from(table).select();
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ getAll $table failed: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getById(String table, String id) async {
    if (!isConfigured) return null;
    try {
      return await _client!.from(table).select().eq('id', id).maybeSingle();
    } catch (e) {
      print('❌ getById $table failed: $e');
      return null;
    }
  }

  Future<void> create(String table, Map<String, dynamic> data) async {
    if (!isConfigured) return;
    try {
      await _client!.from(table).insert(data);
    } catch (e) {
      print('❌ create $table failed: $e');
      rethrow;
    }
  }

  Future<void> insert(String table, Map<String, dynamic> data) => create(table, data);

  Future<void> update(String table, String id, Map<String, dynamic> data) async {
    if (!isConfigured) return;
    try {
      await _client!.from(table).update(data).eq('id', id);
    } catch (e) {
      print('❌ update $table failed: $e');
      rethrow;
    }
  }

  Future<void> delete(String table, String id) async {
    if (!isConfigured) return;
    try {
      await _client!.from(table).delete().eq('id', id);
    } catch (e) {
      print('❌ delete $table failed: $e');
      rethrow;
    }
  }

  Future<String?> uploadImage(String bucket, String path, File file,
      {String? contentType}) async {
    if (!isConfigured) return null;
    final ct = contentType ?? _contentTypeFromPath(path);

    // Ensure bucket exists (silently fails if already exists or no permission)
    try {
      await _client!.storage.createBucket(
        bucket,
        BucketOptions(public: true, fileSizeLimit: '100mb'),
      );
    } catch (_) {}

    final user = _client!.auth.currentUser;
    print('🔑 upload — user: ${user?.id ?? "NOT LOGGED IN"}, bucket: $bucket, path: $path');
    try {
      await _client!.storage.from(bucket).upload(
            path,
            file,
            fileOptions: FileOptions(upsert: true, contentType: ct),
          );
      return _client!.storage.from(bucket).getPublicUrl(path);
    } catch (e) {
      print('❌ uploadImage failed: $e');
      throw Exception('Upload failed: $e');
    }
  }

  static String _contentTypeFromPath(String path) {
    final ext = path.split('.').last.toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg': return 'image/jpeg';
      case 'png':  return 'image/png';
      case 'gif':  return 'image/gif';
      case 'webp': return 'image/webp';
      case 'heic':
      case 'heif': return 'image/heic';
      case 'mp4':  return 'video/mp4';
      case 'mov':  return 'video/quicktime';
      case 'm4v':  return 'video/mp4';
      case 'mp3':  return 'audio/mpeg';
      case 'm4a':  return 'audio/mp4';
      case 'aac':  return 'audio/aac';
      case 'wav':  return 'audio/wav';
      default:     return 'application/octet-stream';
    }
  }

  Future<List<Map<String, dynamic>>> query(
    String table, {
    String? column,
    dynamic value,
    String? orderBy,
    bool ascending = true,
    int? limit,
  }) async {
    if (!isConfigured) return [];
    try {
      dynamic q = _client!.from(table).select();
      if (column != null && value != null) q = (q as dynamic).eq(column, value);
      if (orderBy != null) q = (q as dynamic).order(orderBy, ascending: ascending);
      if (limit != null) q = (q as dynamic).limit(limit);
      final response = await q;
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ query $table failed: $e');
      return [];
    }
  }
}
