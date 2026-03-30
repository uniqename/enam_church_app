import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../models/ministry.dart';
import 'supabase_service.dart';
import 'local_data_service.dart';

class MinistryService {
  static final MinistryService _instance = MinistryService._internal();
  factory MinistryService() => _instance;
  MinistryService._internal();

  final _supabase = SupabaseService();
  final _local = LocalDataService();
  final _uuid = const Uuid();
  static const _localKey = 'local_ministries_override';

  Future<List<Ministry>> _getLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_localKey);
    if (raw == null) return _local.getMinistries();
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((e) => Ministry.fromSupabase(e as Map<String, dynamic>)).toList();
  }

  Future<void> _saveLocal(List<Ministry> ministries) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localKey, jsonEncode(ministries.map((m) => m.toSupabase()).toList()));
  }

  Future<List<Ministry>> getAllMinistries() async {
    if (SupabaseService.isConfigured) {
      try {
        final data = await _supabase.getAll('ministries');
        if (data.isNotEmpty) {
          return data.map((json) => Ministry.fromSupabase(json)).toList();
        }
      } catch (_) {}
    }
    return await _getLocal();
  }

  Future<void> addMinistry({
    required String name,
    required String description,
    required String leader,
    required String meetingDay,
    required String meetingTime,
    required String location,
    required String whatsappGroup,
    List<String>? members,
  }) async {
    final ministry = Ministry(
      id: _uuid.v4(),
      name: name,
      description: description,
      leader: leader,
      meetingDay: meetingDay,
      meetingTime: meetingTime,
      location: location,
      whatsappGroup: whatsappGroup,
      members: members ?? [],
    );
    final list = await _getLocal();
    list.add(ministry);
    await _saveLocal(list);
    if (SupabaseService.isConfigured) {
      try { await _supabase.create('ministries', ministry.toSupabase()); } catch (_) {}
    }
  }

  Future<void> updateMinistry(
    String id, {
    required String name,
    required String description,
    required String leader,
    required String meetingDay,
    required String meetingTime,
    required String location,
    required String whatsappGroup,
    List<String>? members,
  }) async {
    final list = await _getLocal();
    final idx = list.indexWhere((m) => m.id == id);
    final updated = Ministry(
      id: id,
      name: name,
      description: description,
      leader: leader,
      meetingDay: meetingDay,
      meetingTime: meetingTime,
      location: location,
      whatsappGroup: whatsappGroup,
      members: members ?? list[idx >= 0 ? idx : 0].members,
    );
    if (idx >= 0) list[idx] = updated; else list.add(updated);
    await _saveLocal(list);
    if (SupabaseService.isConfigured) {
      try { await _supabase.update('ministries', id, updated.toSupabase()); } catch (_) {}
    }
  }

  Future<void> deleteMinistry(String id) async {
    final list = await _getLocal();
    list.removeWhere((m) => m.id == id);
    await _saveLocal(list);
    if (SupabaseService.isConfigured) {
      try { await _supabase.delete('ministries', id); } catch (_) {}
    }
  }
}
