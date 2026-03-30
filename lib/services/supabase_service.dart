import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  late final SupabaseClient _client;
  SupabaseClient get client => _client;

  Future<void> initialize() async {
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL']!,
      anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    );
    _client = Supabase.instance.client;
    print('✅ Supabase initialized');
  }

  // Auth methods
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'name': name, 'role': role},
      );

      // Create user profile
      if (response.user != null) {
        await _client.from('users').insert({
          'id': response.user!.id,
          'email': email,
          'name': name,
          'role': role,
          'status': 'active',
        });
      }

      print('✅ User signed up: $email');
      return response;
    } catch (e) {
      print('❌ Sign up failed: $e');
      rethrow;
    }
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      print('✅ User signed in: $email');
      return response;
    } catch (e) {
      print('❌ Sign in failed: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
      print('✅ User signed out');
    } catch (e) {
      print('❌ Sign out failed: $e');
      rethrow;
    }
  }

  User? get currentUser => _client.auth.currentUser;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  // Generic CRUD operations
  Future<List<Map<String, dynamic>>> getAll(String table) async {
    try {
      final response = await _client.from(table).select();
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Failed to get all from $table: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getById(String table, String id) async {
    try {
      final response =
          await _client.from(table).select().eq('id', id).maybeSingle();
      return response;
    } catch (e) {
      print('❌ Failed to get $table by id: $e');
      return null;
    }
  }

  Future<void> insert(String table, Map<String, dynamic> data) async {
    try {
      await _client.from(table).insert(data);
      print('✅ Inserted into $table');
    } catch (e) {
      print('❌ Failed to insert into $table: $e');
      rethrow;
    }
  }

  Future<void> update(
      String table, String id, Map<String, dynamic> data) async {
    try {
      await _client.from(table).update(data).eq('id', id);
      print('✅ Updated $table');
    } catch (e) {
      print('❌ Failed to update $table: $e');
      rethrow;
    }
  }

  Future<void> delete(String table, String id) async {
    try {
      await _client.from(table).delete().eq('id', id);
      print('✅ Deleted from $table');
    } catch (e) {
      print('❌ Failed to delete from $table: $e');
      rethrow;
    }
  }

  // Query helper
  Future<List<Map<String, dynamic>>> query(
    String table, {
    String? column,
    dynamic value,
    String? orderBy,
    bool ascending = true,
    int? limit,
  }) async {
    try {
      var query = _client.from(table).select();

      if (column != null && value != null) {
        query = query.eq(column, value);
      }

      if (orderBy != null) {
        query = query.order(orderBy, ascending: ascending);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final response = await query;
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Query failed for $table: $e');
      return [];
    }
  }
}
