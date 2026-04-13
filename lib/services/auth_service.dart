import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user.dart';
import 'supabase_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final _supabase = SupabaseService();

  // Demo accounts for reviewers / offline mode
  static const _demoAccounts = [
    {'email': 'pastor@faithklinik.demo',  'password': 'FaithDemo2026!', 'name': 'Pastor Demo',    'role': 'pastor',    'id': 'demo-pastor-001'},
    {'email': 'admin@faithklinik.demo',   'password': 'FaithDemo2026!', 'name': 'Admin Demo',     'role': 'admin',     'id': 'demo-admin-001'},
    {'email': 'member@faithklinik.demo',  'password': 'FaithDemo2026!', 'name': 'Member Demo',    'role': 'member',    'id': 'demo-member-001'},
    {'email': 'media@faithklinik.demo',   'password': 'FaithDemo2026!', 'name': 'Media Team Demo','role': 'dept_head', 'id': 'demo-media-001', 'department': 'Media Ministry'},
  ];

  // Demo child PINs
  static const _demoPins = ['1234', '5678'];

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    if (SupabaseService.isConfigured) {
      final user = _supabase.currentUser;
      if (user != null) return true;
    }
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id') != null;
  }

  // Get current user (Supabase or demo)
  User? get currentUser => SupabaseService.isConfigured ? _supabase.currentUser : null;

  // Get user role from metadata or demo cache
  Future<String?> getUserRole() async {
    if (SupabaseService.isConfigured) {
      final user = currentUser;
      if (user != null) {
        try {
          final userData = await _supabase.getById('users', user.id);
          final role = userData?['role'] as String?;
          if (role != null) {
            // Keep prefs in sync so offline reads work
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('user_role', role);
            return role;
          }
        } catch (e) {
          print('❌ Failed to get user role from Supabase: $e');
        }
      }
      // No Supabase session (demo login) or query failed — fall back to cached prefs
    }
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_role');
  }

  // Sign in
  Future<AuthResponse> signIn(String email, String password) async {
    if (!SupabaseService.isConfigured) {
      return _demoSignIn(email, password);
    }
    // Try real Supabase auth first (works for both real and demo accounts
    // that exist in Supabase — gives a valid JWT so uploads work)
    try {
      final response = await _supabase.signIn(email: email, password: password);
      if (response.user != null) await _cacheUserSession(response.user!);
      return response;
    } catch (e) {
      // Fall back to local demo only if Supabase account doesn't exist
      if (email.trim().toLowerCase().endsWith('.demo')) {
        return _demoSignIn(email, password);
      }
      print('❌ Auth service sign in failed: $e');
      rethrow;
    }
  }

  // Demo sign-in — checks hardcoded accounts
  Future<AuthResponse> _demoSignIn(String email, String password) async {
    final match = _demoAccounts.firstWhere(
      (a) => a['email'] == email.trim().toLowerCase() && a['password'] == password,
      orElse: () => {},
    );
    if (match.isEmpty) {
      throw Exception('Invalid demo credentials. Try pastor/admin/member/media @faithklinik.demo with FaithDemo2026!');
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id',         match['id']!);
    await prefs.setString('user_email',      match['email']!);
    await prefs.setString('user_name',       match['name']!);
    await prefs.setString('user_role',       match['role']!);
    await prefs.setString('user_department', match['department'] ?? '');
    print('✅ Demo sign-in: ${match['role']}');
    // Return a minimal AuthResponse — user is null (demo mode), session is null
    return AuthResponse(session: null, user: null);
  }

  // Child PIN login
  Future<bool> childPinLogin(String pin) async {
    if (!SupabaseService.isConfigured) {
      final valid = _demoPins.contains(pin);
      if (valid) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_id',    'demo-child-001');
        await prefs.setString('user_email', 'child@faithklinik.org');
        await prefs.setString('user_name',  'Children User');
        await prefs.setString('user_role',  'child');
        print('✅ Demo child PIN login');
      }
      return valid;
    }
    try {
      final result = await _supabase.query(
        'child_accounts',
        column: 'pin',
        value: pin,
      );
      if (result.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_id',   result.first['id'] as String? ?? '');
        await prefs.setString('user_role', 'child');
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Child PIN login failed: $e');
      return false;
    }
  }

  // Sign up
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    if (!SupabaseService.isConfigured) {
      // Demo mode: just cache and return empty response
      final prefs = await SharedPreferences.getInstance();
      final id = 'demo-${DateTime.now().millisecondsSinceEpoch}';
      await prefs.setString('user_id',    id);
      await prefs.setString('user_email', email);
      await prefs.setString('user_name',  name);
      await prefs.setString('user_role',  role);
      return AuthResponse(session: null, user: null);
    }
    try {
      final response = await _supabase.signUp(
        email: email,
        password: password,
        name: name,
        role: role,
      );
      if (response.user != null) await _cacheUserSession(response.user!);
      return response;
    } catch (e) {
      print('❌ Auth service sign up failed: $e');
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      if (SupabaseService.isConfigured) await _supabase.signOut();
      await _clearUserSession();
    } catch (e) {
      print('❌ Auth service sign out failed: $e');
      rethrow;
    }
  }

  // Cache user session
  Future<void> _cacheUserSession(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id',    user.id);
    await prefs.setString('user_email', user.email ?? '');
    // Prefer role from users table; fall back to metadata then 'member'
    String role = user.userMetadata?['role'] as String? ?? 'member';
    try {
      final userData = await _supabase.getById('users', user.id);
      role = userData?['role'] as String? ?? role;
    } catch (_) {}
    await prefs.setString('user_role', role);
    print('✅ User session cached with role: $role');
  }

  // Clear user session
  Future<void> _clearUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    await prefs.remove('user_email');
    await prefs.remove('user_name');
    await prefs.remove('user_role');
    print('✅ User session cleared');
  }

  // Helper methods used by screens
  Future<String?> getCurrentUserId() async {
    if (SupabaseService.isConfigured && currentUser != null) return currentUser!.id;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }

  Future<String?> getCurrentUserName() async {
    if (SupabaseService.isConfigured && currentUser != null) {
      return currentUser!.userMetadata?['name'] as String?;
    }
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_name');
  }

  Future<String?> getUserDepartment() async {
    if (!SupabaseService.isConfigured) return null;
    final user = currentUser;
    if (user == null) return null;
    try {
      final data = await _supabase.getById('users', user.id);
      return data?['department'] as String?;
    } catch (_) { return null; }
  }

  Future<AppUser?> getCurrentUserProfile() async {
    final prefs = await SharedPreferences.getInstance();

    // If Supabase is configured and we have a live session, try the DB first
    if (SupabaseService.isConfigured && currentUser != null) {
      try {
        final data = await _supabase.getById('users', currentUser!.id);
        if (data != null) {
          // Keep prefs in sync for offline fallback
          await prefs.setString('user_role', data['role'] as String? ?? 'member');
          await prefs.setString('user_department', data['department'] as String? ?? '');
          await prefs.setString('user_name', data['name'] as String? ?? '');
          return AppUser.fromSupabase(data);
        }
      } catch (_) {}
    }

    // Fallback: build profile from cached SharedPreferences
    // This covers demo users, expired sessions, and Supabase query failures.
    final id = prefs.getString('user_id') ??
        (SupabaseService.isConfigured ? currentUser?.id : null);
    if (id == null) return null;
    final role = prefs.getString('user_role') ?? 'member';
    return AppUser(
      id: id,
      email: prefs.getString('user_email') ?? currentUser?.email ?? '',
      name: prefs.getString('user_name') ??
          currentUser?.userMetadata?['name'] as String? ?? 'User',
      phone: '',
      role: _roleFromString(role),
      department: prefs.getString('user_department') ?? '',
      status: 'active',
    );
  }

  static UserRole _roleFromString(String role) {
    switch (role.toLowerCase()) {
      case 'pastor':          return UserRole.pastor;
      case 'admin':           return UserRole.admin;
      case 'department_head':
      case 'dept_head':       return UserRole.dept_head;
      case 'media_team':      return UserRole.media_team;
      case 'treasurer':       return UserRole.treasurer;
      case 'child':           return UserRole.child;
      default:                return UserRole.member;
    }
  }

  Future<String?> getCurrentUserEmail() async {
    if (SupabaseService.isConfigured && currentUser != null) return currentUser!.email;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_email');
  }
}
