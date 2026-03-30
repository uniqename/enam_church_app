import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../models/church_group.dart';
import 'supabase_service.dart';

class ChurchGroupService {
  static final ChurchGroupService _instance = ChurchGroupService._internal();
  factory ChurchGroupService() => _instance;
  ChurchGroupService._internal();

  final _supabase = SupabaseService();
  final _uuid = const Uuid();
  static const _localKey = 'local_church_groups';

  Future<List<ChurchGroup>> _getLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_localKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((e) => ChurchGroup.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> _saveLocal(List<ChurchGroup> groups) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localKey, jsonEncode(groups.map((g) => g.toJson()).toList()));
  }

  Future<List<ChurchGroup>> getAllGroups() async {
    if (SupabaseService.isConfigured) {
      try {
        final data = await _supabase.getAll('church_groups');
        if (data.isNotEmpty) {
          return data.map((json) => ChurchGroup.fromJson(json)).toList();
        }
      } catch (_) {}
    }
    return await _getLocal();
  }

  Future<void> addGroup({
    required String name,
    required String description,
    required String leader,
    required String meetingDay,
    required String meetingTime,
    required String location,
    required String whatsappGroup,
  }) async {
    final group = ChurchGroup(
      id: _uuid.v4(),
      name: name,
      description: description,
      leaders: leader.isNotEmpty ? [leader] : [],
      members: [],
      meetingDay: meetingDay,
      meetingTime: meetingTime,
      location: location,
      whatsappGroup: whatsappGroup,
    );
    final groups = await _getLocal();
    groups.add(group);
    await _saveLocal(groups);
    if (SupabaseService.isConfigured) {
      try { await _supabase.create('church_groups', group.toJson()); } catch (_) {}
    }
  }

  Future<void> updateGroup(
    String id, {
    required String name,
    required String description,
    String? leader,
    List<String>? members,
    String? meetingDay,
    String? meetingTime,
    String? location,
    String? whatsappGroup,
  }) async {
    final groups = await _getLocal();
    final idx = groups.indexWhere((g) => g.id == id);
    final existing = idx >= 0 ? groups[idx] : null;
    final updated = ChurchGroup(
      id: id,
      name: name,
      description: description,
      leaders: leader != null && leader.isNotEmpty
          ? [leader]
          : existing?.leaders ?? [],
      members: members ?? existing?.members ?? [],
      meetingDay: meetingDay ?? existing?.meetingDay ?? '',
      meetingTime: meetingTime ?? existing?.meetingTime ?? '',
      location: location ?? existing?.location ?? '',
      whatsappGroup: whatsappGroup ?? existing?.whatsappGroup ?? '',
    );
    if (idx >= 0) groups[idx] = updated; else groups.add(updated);
    await _saveLocal(groups);
    if (SupabaseService.isConfigured) {
      try { await _supabase.update('church_groups', id, updated.toJson()); } catch (_) {}
    }
  }

  Future<void> deleteGroup(String id) async {
    final groups = await _getLocal();
    groups.removeWhere((g) => g.id == id);
    await _saveLocal(groups);
    if (SupabaseService.isConfigured) {
      try { await _supabase.delete('church_groups', id); } catch (_) {}
    }
  }
}
