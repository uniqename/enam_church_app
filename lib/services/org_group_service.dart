import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/org_group.dart';
import 'supabase_service.dart';
import 'local_data_service.dart';

class OrgGroupService {
  static final OrgGroupService _instance = OrgGroupService._internal();
  factory OrgGroupService() => _instance;
  OrgGroupService._internal();

  final _supabase = SupabaseService();
  final _local = LocalDataService();

  static const String _overridesKey = 'local_org_group_overrides';
  static const String _deletedKey = 'local_org_group_deleted';

  Future<Map<String, Map<String, dynamic>>> _getOverrides() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_overridesKey);
    if (raw == null) return {};
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map((k, v) => MapEntry(k, v as Map<String, dynamic>));
  }

  Future<void> _saveOverride(String id, Map<String, dynamic> data) async {
    final overrides = await _getOverrides();
    overrides[id] = data;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_overridesKey, jsonEncode(overrides));
  }

  Future<Set<String>> _getDeletedIds() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_deletedKey);
    if (raw == null) return {};
    return Set<String>.from(jsonDecode(raw) as List<dynamic>);
  }

  Future<void> _markDeleted(String id) async {
    final deleted = await _getDeletedIds();
    deleted.add(id);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_deletedKey, jsonEncode(deleted.toList()));
  }

  Future<List<OrgGroup>> getAllGroups() async {
    if (SupabaseService.isConfigured) {
      try {
        final data = await _supabase.getAll('groups');
        if (data.isNotEmpty) {
          return data.map((json) => OrgGroup.fromJson(json)).toList();
        }
      } catch (e) {
        print('⚠️ Supabase unavailable, using local groups: $e');
      }
    }

    final seed = _local.getGroups();
    final overrides = await _getOverrides();
    final deleted = await _getDeletedIds();

    final result = seed
        .where((g) => !deleted.contains(g.id))
        .map((group) {
          final ov = overrides[group.id];
          if (ov == null) return group;
          return OrgGroup.fromJson({...group.toJson(), ...ov});
        })
        .toList();

    // Append locally-created groups
    for (final entry in overrides.entries) {
      if (entry.key.startsWith('grp-local-') && !deleted.contains(entry.key)) {
        result.add(OrgGroup.fromJson({'id': entry.key, ...entry.value}));
      }
    }
    return result;
  }

  Future<void> addGroup({
    required String name,
    required String description,
    required List<String> leaders,
    required String meetingDay,
    required String meetingTime,
    required String location,
    required String whatsappGroup,
  }) async {
    final payload = {
      'name': name,
      'description': description,
      'leaders': leaders,
      'members': <String>[],
      'meeting_day': meetingDay,
      'meeting_time': meetingTime,
      'location': location,
      'whatsapp_group': whatsappGroup,
    };

    if (SupabaseService.isConfigured) {
      try {
        await _supabase.insert('groups', payload);
        print('✅ Group added: $name');
        return;
      } catch (e) {
        print('⚠️ Supabase insert failed, saving locally: $e');
      }
    }

    final id = 'grp-local-${DateTime.now().millisecondsSinceEpoch}';
    await _saveOverride(id, payload);
    print('✅ Group added locally: $name');
  }

  Future<void> updateGroup(
    String id, {
    required String name,
    required String description,
    required List<String> leaders,
    required List<String> members,
    required String meetingDay,
    required String meetingTime,
    required String location,
    required String whatsappGroup,
  }) async {
    final payload = {
      'name': name,
      'description': description,
      'leaders': leaders,
      'members': members,
      'meeting_day': meetingDay,
      'meeting_time': meetingTime,
      'location': location,
      'whatsapp_group': whatsappGroup,
    };

    if (SupabaseService.isConfigured) {
      try {
        await _supabase.update('groups', id, payload);
        print('✅ Group updated: $name');
        return;
      } catch (e) {
        print('⚠️ Supabase update failed, saving locally: $e');
      }
    }

    await _saveOverride(id, payload);
    print('✅ Group updated locally: $name');
  }

  Future<void> deleteGroup(String id) async {
    if (SupabaseService.isConfigured) {
      try {
        await _supabase.delete('groups', id);
        print('✅ Group deleted: $id');
        return;
      } catch (e) {
        print('⚠️ Supabase delete failed, marking locally: $e');
      }
    }
    final overrides = await _getOverrides();
    if (overrides.containsKey(id)) {
      overrides.remove(id);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_overridesKey, jsonEncode(overrides));
    }
    await _markDeleted(id);
    print('✅ Group deleted locally: $id');
  }
}
