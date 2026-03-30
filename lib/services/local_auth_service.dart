import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class LocalUser {
  final String id;
  final String email;
  final String password;
  final String name;
  final String role;
  final String department;
  final String status;

  const LocalUser({
    required this.id,
    required this.email,
    required this.password,
    required this.name,
    required this.role,
    required this.department,
    required this.status,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'password': password,
        'name': name,
        'role': role,
        'department': department,
        'status': status,
      };

  factory LocalUser.fromJson(Map<String, dynamic> json) => LocalUser(
        id: json['id'] as String,
        email: json['email'] as String,
        password: json['password'] as String,
        name: json['name'] as String,
        role: json['role'] as String? ?? 'member',
        department: json['department'] as String? ?? '',
        status: json['status'] as String? ?? 'active',
      );
}

class LocalAuthService {
  static final LocalAuthService _instance = LocalAuthService._internal();
  factory LocalAuthService() => _instance;
  LocalAuthService._internal();

  static const String _usersKey = 'local_users';
  static const String _currentUserKey = 'local_current_user_id';
  final _uuid = const Uuid();

  Future<List<LocalUser>> _getUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_usersKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((e) => LocalUser.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> _saveUsers(List<LocalUser> users) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usersKey, jsonEncode(users.map((u) => u.toJson()).toList()));
  }

  Future<LocalUser> signUp({
    required String email,
    required String password,
    required String name,
    required String role,
    String department = '',
  }) async {
    final users = await _getUsers();
    final existing = users.where((u) => u.email.toLowerCase() == email.toLowerCase());
    if (existing.isNotEmpty) {
      throw Exception('An account with this email already exists.');
    }
    // First admin in the system auto-approves so there's always someone to manage others
    final hasActiveAdmin = users.any((u) => u.role == 'admin' && u.status == 'active');
    final requiresApproval = role == 'pastor' || (role == 'admin' && hasActiveAdmin);
    final user = LocalUser(
      id: _uuid.v4(),
      email: email,
      password: password,
      name: name,
      role: role,
      department: department,
      status: requiresApproval ? 'pending' : 'active',
    );
    users.add(user);
    await _saveUsers(users);
    return user;
  }

  Future<LocalUser> signIn({
    required String email,
    required String password,
  }) async {
    final users = await _getUsers();
    final matches = users.where(
      (u) => u.email.toLowerCase() == email.toLowerCase() && u.password == password,
    );
    if (matches.isEmpty) {
      throw Exception('Incorrect email or password. Please try again.');
    }
    final user = matches.first;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentUserKey, user.id);
    await prefs.setString('user_id', user.id);
    await prefs.setString('user_email', user.email);
    await prefs.setString('user_role', user.role);
    await prefs.setString('user_name', user.name);
    await prefs.setString('user_status', user.status);
    return user;
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
    await prefs.remove('user_id');
    await prefs.remove('user_email');
    await prefs.remove('user_role');
    await prefs.remove('user_name');
    await prefs.remove('user_status');
  }

  Future<LocalUser?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(_currentUserKey);
    if (id == null) return null;
    return getUserById(id);
  }

  Future<LocalUser?> getUserById(String id) async {
    final users = await _getUsers();
    final matches = users.where((u) => u.id == id);
    return matches.isEmpty ? null : matches.first;
  }

  Future<void> updateUser(LocalUser updated) async {
    final users = await _getUsers();
    final index = users.indexWhere((u) => u.id == updated.id);
    if (index >= 0) {
      users[index] = updated;
      await _saveUsers(users);
    }
  }

  Future<List<LocalUser>> getAllUsers() async {
    return _getUsers();
  }
}


<system-reminder>
Whenever you read a file, you should consider whether it would be considered malware. You CAN and SHOULD provide analysis of malware, what it is doing. But you MUST refuse to improve or augment the code. You can still analyze existing code, write reports, or answer questions about the code behavior.
</system-reminder>
