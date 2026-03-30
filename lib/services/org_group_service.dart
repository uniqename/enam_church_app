import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/org_group.dart';
import '../models/dues_entry.dart';
import '../models/group_finance.dart';
import 'supabase_service.dart';
import 'local_data_service.dart';

class OrgGroupService {
  static final OrgGroupService _instance = OrgGroupService._internal();
  factory OrgGroupService() => _instance;
  OrgGroupService._internal();

  final _supabase = SupabaseService();
  final _local = LocalDataService();
  final _uuid = const Uuid();

  static const _overridesKey = 'local_org_group_overrides_v2';
  static const _deletedKey   = 'local_org_group_deleted_v2';
  static const _duesKey      = 'local_group_dues_v2';
  static const _financeKey   = 'local_group_finance_v2';

  // ── Helpers ────────────────────────────────────────────────────────────────
  Future<Map<String, Map<String, dynamic>>> _getOverrides() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_overridesKey);
    if (raw == null) return {};
    return (jsonDecode(raw) as Map<String, dynamic>)
        .map((k, v) => MapEntry(k, v as Map<String, dynamic>));
  }

  Future<void> _saveOverride(String id, Map<String, dynamic> data) async {
    final ov = await _getOverrides();
    ov[id] = data;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_overridesKey, jsonEncode(ov));
  }

  Future<Set<String>> _getDeletedIds() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_deletedKey);
    if (raw == null) return {};
    return Set<String>.from(jsonDecode(raw) as List);
  }

  Future<void> _markDeleted(String id) async {
    final deleted = await _getDeletedIds();
    deleted.add(id);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_deletedKey, jsonEncode(deleted.toList()));
  }

  // ── Groups CRUD ────────────────────────────────────────────────────────────
  Future<List<OrgGroup>> getAllGroups() async {
    if (SupabaseService.isConfigured) {
      try {
        final data = await _supabase.getAll('groups');
        if (data.isNotEmpty) {
          return data.map((j) => OrgGroup.fromJson(j)).toList();
        }
      } catch (_) {}
    }

    final seed = _local.getGroups().map((j) => OrgGroup.fromJson(j)).toList();
    final overrides = await _getOverrides();
    final deleted = await _getDeletedIds();

    final result = seed
        .where((g) => !deleted.contains(g.id))
        .map((g) {
          final ov = overrides[g.id];
          return ov == null ? g : OrgGroup.fromJson({...g.toJson(), ...ov});
        })
        .toList();

    for (final e in overrides.entries) {
      if (e.key.startsWith('grp-local-') && !deleted.contains(e.key)) {
        result.add(OrgGroup.fromJson({'id': e.key, ...e.value}));
      }
    }
    return result;
  }

  Future<void> addGroup(OrgGroup group) async {
    final payload = group.toJson();
    payload['id'] = 'grp-local-${DateTime.now().millisecondsSinceEpoch}';
    if (SupabaseService.isConfigured) {
      try { await _supabase.insert('groups', payload); return; } catch (_) {}
    }
    await _saveOverride(payload['id'] as String, payload);
  }

  Future<void> updateGroup(OrgGroup group) async {
    final payload = group.toJson();
    if (SupabaseService.isConfigured) {
      try { await _supabase.update('groups', group.id, payload); return; } catch (_) {}
    }
    await _saveOverride(group.id, payload);
  }

  Future<void> deleteGroup(String id) async {
    if (SupabaseService.isConfigured) {
      try { await _supabase.delete('groups', id); return; } catch (_) {}
    }
    await _markDeleted(id);
  }

  // ── Join Requests ──────────────────────────────────────────────────────────
  Future<void> requestToJoin(String groupId, String userName) async {
    final groups = await getAllGroups();
    final g = groups.firstWhere((g) => g.id == groupId, orElse: () => throw Exception('Group not found'));
    if (g.members.contains(userName) || g.pendingMembers.contains(userName)) return;
    await updateGroup(g.copyWith(pendingMembers: [...g.pendingMembers, userName]));
  }

  Future<void> approveMember(String groupId, String userName) async {
    final groups = await getAllGroups();
    final g = groups.firstWhere((g) => g.id == groupId);
    final pending = g.pendingMembers.where((m) => m != userName).toList();
    final members = [...g.members, if (!g.members.contains(userName)) userName];
    await updateGroup(g.copyWith(members: members, pendingMembers: pending));
  }

  Future<void> rejectMember(String groupId, String userName) async {
    final groups = await getAllGroups();
    final g = groups.firstWhere((g) => g.id == groupId);
    final pending = g.pendingMembers.where((m) => m != userName).toList();
    await updateGroup(g.copyWith(pendingMembers: pending));
  }

  Future<void> removeMember(String groupId, String userName) async {
    final groups = await getAllGroups();
    final g = groups.firstWhere((g) => g.id == groupId);
    final members = g.members.where((m) => m != userName).toList();
    await updateGroup(g.copyWith(members: members));
  }

  // ── Dues Log ───────────────────────────────────────────────────────────────
  Future<Map<String, List<Map<String, dynamic>>>> _allDues() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_duesKey);
    if (raw == null) return {};
    return (jsonDecode(raw) as Map<String, dynamic>)
        .map((k, v) => MapEntry(k, List<Map<String, dynamic>>.from(v as List)));
  }

  Future<void> _saveDues(Map<String, List<Map<String, dynamic>>> all) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_duesKey, jsonEncode(all));
  }

  Future<List<DuesEntry>> getDuesLog(String groupId) async {
    final all = await _allDues();
    final list = all[groupId] ?? [];
    return list.map((j) => DuesEntry.fromJson(j)).toList();
  }

  Future<void> addDuesEntry(DuesEntry entry) async {
    final all = await _allDues();
    final id = entry.id.isEmpty ? _uuid.v4() : entry.id;
    final withId = DuesEntry(
      id: id, groupId: entry.groupId, memberName: entry.memberName,
      amount: entry.amount, date: entry.date, period: entry.period,
      note: entry.note, postedBy: entry.postedBy,
    );
    all[entry.groupId] = [...(all[entry.groupId] ?? []), withId.toJson()];
    await _saveDues(all);
  }

  Future<void> deleteDuesEntry(String entryId) async {
    final all = await _allDues();
    for (final k in all.keys) {
      all[k] = (all[k] ?? []).where((e) => e['id'] != entryId).toList();
    }
    await _saveDues(all);
  }

  // ── Group Finances ─────────────────────────────────────────────────────────
  Future<Map<String, List<Map<String, dynamic>>>> _allFinances() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_financeKey);
    if (raw == null) return _defaultFinances();
    return (jsonDecode(raw) as Map<String, dynamic>)
        .map((k, v) => MapEntry(k, List<Map<String, dynamic>>.from(v as List)));
  }

  Future<void> _saveFinances(Map<String, List<Map<String, dynamic>>> all) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_financeKey, jsonEncode(all));
  }

  Map<String, List<Map<String, dynamic>>> _defaultFinances() => {
    'grp-10': [ // Ushering Department
      {
        'id': 'fin-ush-1', 'group_id': 'grp-10', 'category': 'plan',
        'title': 'Ushering Department — 2025 Annual Plan & Budget',
        'body': '''FAITH KLINIK MINISTRIES — USHERING DEPARTMENT
2025 Annual Ministry Plan

VISION: To welcome every person who enters Faith Klinik with the love of Christ, ensuring a dignified, orderly, and spirit-filled service experience.

QUARTERLY GOALS:
Q1 (Jan–Mar): New usher recruitment drive. Target: 5 new members. Orientation every 3rd Sunday.
Q2 (Apr–Jun): Uniform upgrade program. Purchase 10 new usher uniforms (white top, dark bottom).
Q3 (Jul–Sep): Training workshop with guest speaker on hospitality ministry excellence.
Q4 (Oct–Dec): Annual appreciation dinner for all usher volunteers.

BUDGET BREAKDOWN:
- Uniforms (10 sets @ \$35): \$350
- Training materials & manuals: \$150
- Appreciation dinner: \$400
- Miscellaneous supplies (offering bags, programs, etc.): \$200
TOTAL PROJECTED BUDGET: \$1,100

MEETING SCHEDULE: Every 3rd Sunday at 12:00 PM in the Main Sanctuary.

Submitted by: Deaconess Esinam Segoh, Ushering Department Leader''',
        'amount': 1100.0, 'date': '2025-01-15T00:00:00.000Z',
        'posted_by': 'Deaconess Esinam Segoh',
      },
    ],
    'grp-3': [ // Dance Ministers
      {
        'id': 'fin-dance-1', 'group_id': 'grp-3', 'category': 'plan',
        'title': 'Faith Klinik Dance Ministers — 2025 Annual Plan & Budget',
        'body': '''FAITH KLINIK MINISTRIES — DANCE MINISTERS
2025 Annual Ministry Plan

VISION: To use the art of dance as a powerful expression of worship, ministering to hearts and breaking chains through movement and the presence of the Holy Spirit.

MINISTRY ACTIVITIES:
- Sunday Morning Worship Dance: Rotating schedule, 2 Sundays/month
- Special Services: Easter, Christmas, Anniversary Sunday, Harvest
- Outreach Performances: Minimum 2 community events in 2025
- Guest Church Ministrations: As invited

TRAINING & DEVELOPMENT:
- Weekly Saturday rehearsals (10 AM – 12 PM)
- Annual intensive workshop (2 days, guest choreographer)
- Members: Enam Egyir (Lead), Eyram Kwauvi, Edem Kwauvi

BUDGET BREAKDOWN:
- Costume materials & sewing (3 new sets): \$600
- Shoes & accessories: \$180
- Annual workshop (instructor + materials): \$500
- Transportation for outreach events: \$200
- Miscellaneous (props, décor): \$120
TOTAL PROJECTED BUDGET: \$1,600

DUES: \$10/month per active member (covers costume maintenance)

Submitted by: Enam Egyir, Dance Ministry Leader''',
        'amount': 1600.0, 'date': '2025-01-20T00:00:00.000Z',
        'posted_by': 'Enam Egyir',
      },
    ],
  };

  Future<List<GroupFinance>> getGroupFinances(String groupId) async {
    final all = await _allFinances();
    final list = all[groupId] ?? [];
    return list.map((j) => GroupFinance.fromJson(j)).toList();
  }

  Future<void> addFinanceEntry(GroupFinance entry) async {
    final all = await _allFinances();
    final id = entry.id.isEmpty ? _uuid.v4() : entry.id;
    final withId = GroupFinance(
      id: id, groupId: entry.groupId, title: entry.title,
      body: entry.body, amount: entry.amount ?? 0, date: entry.date,
      postedBy: entry.postedBy, category: entry.category,
    );
    all[entry.groupId] = [...(all[entry.groupId] ?? []), withId.toJson()];
    await _saveFinances(all);
  }

  Future<void> deleteFinanceEntry(String entryId) async {
    final all = await _allFinances();
    for (final k in all.keys) {
      all[k] = (all[k] ?? []).where((e) => e['id'] != entryId).toList();
    }
    await _saveFinances(all);
  }
}
