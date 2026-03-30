import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../models/department.dart';
import 'supabase_service.dart';
import 'local_data_service.dart';

class DepartmentService {
  static final DepartmentService _instance = DepartmentService._internal();
  factory DepartmentService() => _instance;
  DepartmentService._internal();

  final _supabase = SupabaseService();
  final _local = LocalDataService();
  final _uuid = const Uuid();
  static const _localKey = 'local_departments_override';

  Future<List<Department>> _getLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_localKey);
    if (raw == null) return _local.getDepartments();
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((e) => Department.fromSupabase(e as Map<String, dynamic>)).toList();
  }

  Future<void> _saveLocal(List<Department> depts) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localKey, jsonEncode(depts.map((d) => d.toSupabase()).toList()));
  }

  Future<List<Department>> getAllDepartments() async {
    if (SupabaseService.isConfigured) {
      try {
        final data = await _supabase.getAll('departments');
        if (data.isNotEmpty) {
          return data.map((json) => Department.fromSupabase(json)).toList();
        }
      } catch (_) {}
    }
    return await _getLocal();
  }

  Future<void> addDepartment({
    required String name,
    required String head,
    required String whatsappGroup,
    List<String>? members,
  }) async {
    final dept = Department(
      id: _uuid.v4(),
      name: name,
      heads: head.isNotEmpty ? [head] : [],
      members: members ?? [],
      whatsappGroup: whatsappGroup,
      slackChannel: '',
    );
    final depts = await _getLocal();
    depts.add(dept);
    await _saveLocal(depts);
    if (SupabaseService.isConfigured) {
      try { await _supabase.create('departments', dept.toSupabase()); } catch (_) {}
    }
  }

  Future<void> updateDepartment(
    String id, {
    required String name,
    required String head,
    required String whatsappGroup,
    List<String>? members,
  }) async {
    final depts = await _getLocal();
    final idx = depts.indexWhere((d) => d.id == id);
    final existing = idx >= 0 ? depts[idx] : null;
    final updated = Department(
      id: id,
      name: name,
      heads: head.isNotEmpty ? [head] : existing?.heads ?? [],
      members: members ?? existing?.members ?? [],
      whatsappGroup: whatsappGroup,
      slackChannel: existing?.slackChannel ?? '',
    );
    if (idx >= 0) depts[idx] = updated; else depts.add(updated);
    await _saveLocal(depts);
    if (SupabaseService.isConfigured) {
      try { await _supabase.update('departments', id, updated.toSupabase()); } catch (_) {}
    }
  }

  Future<void> deleteDepartment(String id) async {
    final depts = await _getLocal();
    depts.removeWhere((d) => d.id == id);
    await _saveLocal(depts);
    if (SupabaseService.isConfigured) {
      try { await _supabase.delete('departments', id); } catch (_) {}
    }
  }
}
