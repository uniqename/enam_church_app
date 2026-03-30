import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final _supabase = SupabaseService();

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final user = _supabase.currentUser;
    if (user != null) {
      // Also check SharedPreferences for cached session
      final prefs = await SharedPreferences.getInstance();
      final cachedUserId = prefs.getString('user_id');
      return cachedUserId != null;
    }
    return false;
  }

  // Get current user
  User? get currentUser => _supabase.currentUser;

  // Get user role from metadata
  Future<String?> getUserRole() async {
    final user = currentUser;
    if (user == null) return null;

    try {
      final userData = await _supabase.getById('users', user.id);
      return userData?['role'] as String?;
    } catch (e) {
      print('❌ Failed to get user role: $e');
      return null;
    }
  }

  // Sign in
  Future<AuthResponse> signIn(String email, String password) async {
    try {
      final response = await _supabase.signIn(
        email: email,
        password: password,
      );

      if (response.user != null) {
        await _cacheUserSession(response.user!);
      }

      return response;
    } catch (e) {
      print('❌ Auth service sign in failed: $e');
      rethrow;
    }
  }

  // Sign up
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    try {
      final response = await _supabase.signUp(
        email: email,
        password: password,
        name: name,
        role: role,
      );

      if (response.user != null) {
        await _cacheUserSession(response.user!);
      }

      return response;
    } catch (e) {
      print('❌ Auth service sign up failed: $e');
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _supabase.signOut();
      await _clearUserSession();
    } catch (e) {
      print('❌ Auth service sign out failed: $e');
      rethrow;
    }
  }

  // Cache user session
  Future<void> _cacheUserSession(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', user.id);
    await prefs.setString('user_email', user.email ?? '');
    print('✅ User session cached');
  }

  // Clear user session
  Future<void> _clearUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    await prefs.remove('user_email');
    print('✅ User session cleared');
  }
}
