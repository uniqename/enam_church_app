import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/child_account.dart';
import 'supabase_service.dart';

const String _kChildAccountsKey = 'child_accounts';
const String _kActiveChildKey = 'active_child_account_id';
const String _kDemoSeededKey = 'child_demo_seeded_v1';

class ChildAccountService {
  static final ChildAccountService _instance = ChildAccountService._internal();
  factory ChildAccountService() => _instance;
  ChildAccountService._internal();

  final _supabase = SupabaseService();

  // --------------- Local helpers ---------------

  Future<List<ChildAccount>> _localAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kChildAccountsKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => ChildAccount.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> _saveLocal(List<ChildAccount> accounts) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _kChildAccountsKey,
        jsonEncode(accounts.map((a) => a.toJson()).toList()));
  }

  /// Seeds Emma (1234) and Junior (5678) demo accounts on first launch.
  Future<void> _ensureDemoAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_kDemoSeededKey) == true) return;

    final existing = await _localAccounts();
    final names = existing.map((a) => a.accountName.toLowerCase()).toSet();

    final toAdd = <ChildAccount>[];
    if (!names.contains('emma')) {
      toAdd.add(ChildAccount.create(
        parentUserId: 'demo',
        accountName: 'Emma',
        pin: '1234',
        ageYears: 8,
      ));
    }
    if (!names.contains('junior')) {
      toAdd.add(ChildAccount.create(
        parentUserId: 'demo',
        accountName: 'Junior',
        pin: '5678',
        ageYears: 10,
      ));
    }
    if (toAdd.isNotEmpty) {
      await _saveLocal([...existing, ...toAdd]);
    }
    await prefs.setBool(_kDemoSeededKey, true);
  }

  // --------------- Public API ---------------

  /// Returns all locally stored child accounts (used on the login screen).
  /// Also seeds demo accounts on first call.
  Future<List<ChildAccount>> getAllLocalAccounts() async {
    await _ensureDemoAccounts();

    // If Supabase is configured, merge remote accounts into local so
    // they are always visible even after reinstall.
    if (SupabaseService.isConfigured) {
      try {
        final data = await _supabase.client
            .from('child_accounts')
            .select()
            .order('created_at');
        final remote = (data as List<dynamic>)
            .map((e) => ChildAccount.fromJson(e as Map<String, dynamic>))
            .toList();
        if (remote.isNotEmpty) {
          // Merge: keep local, add any remote not already stored locally
          final local = await _localAccounts();
          final localIds = {for (final a in local) a.id};
          final toMerge =
              remote.where((a) => !localIds.contains(a.id)).toList();
          if (toMerge.isNotEmpty) {
            await _saveLocal([...local, ...toMerge]);
          }
          // Return merged list
          final merged = await _localAccounts();
          return merged;
        }
      } catch (_) {}
    }

    return _localAccounts();
  }

  /// Returns all child accounts for a given parent.
  Future<List<ChildAccount>> getAccountsForParent(String parentUserId) async {
    try {
      if (SupabaseService.isConfigured) {
        final data = await _supabase.client
            .from('child_accounts')
            .select()
            .eq('parent_user_id', parentUserId)
            .order('created_at');
        return (data as List<dynamic>)
            .map((e) => ChildAccount.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
    final all = await _localAccounts();
    return all.where((a) => a.parentUserId == parentUserId).toList();
  }

  /// Creates a new child account.
  /// Always saves locally AND attempts Supabase — never loses data.
  Future<ChildAccount> createAccount({
    required String parentUserId,
    required String accountName,
    required String pin,
    int ageYears = 0,
  }) async {
    final account = ChildAccount.create(
      parentUserId: parentUserId,
      accountName: accountName,
      pin: pin,
      ageYears: ageYears,
    );

    // Always save locally first — this is the source of truth for the login screen.
    final all = await _localAccounts();
    all.add(account);
    await _saveLocal(all);

    // Then attempt Supabase in the background (non-blocking failure).
    if (SupabaseService.isConfigured) {
      try {
        await _supabase.client.from('child_accounts').insert(account.toJson());
      } catch (_) {
        // Local save already done — Supabase failure is non-fatal.
      }
    }

    return account;
  }

  /// Updates an existing child account.
  Future<void> updateAccount(ChildAccount account) async {
    // Update locally first.
    final all = await _localAccounts();
    final idx = all.indexWhere((a) => a.id == account.id);
    if (idx != -1) all[idx] = account;
    await _saveLocal(all);

    try {
      if (SupabaseService.isConfigured) {
        await _supabase.client
            .from('child_accounts')
            .update(account.toJson())
            .eq('id', account.id);
      }
    } catch (_) {}
  }

  /// Deletes a child account.
  Future<void> deleteAccount(String accountId) async {
    // Remove locally first.
    final all = await _localAccounts();
    all.removeWhere((a) => a.id == accountId);
    await _saveLocal(all);

    try {
      if (SupabaseService.isConfigured) {
        await _supabase.client
            .from('child_accounts')
            .delete()
            .eq('id', accountId);
      }
    } catch (_) {}
  }

  /// Verifies a PIN for a given account. Returns the account if valid.
  Future<ChildAccount?> verifyPin(String accountId, String pin) async {
    try {
      // Check local first (fastest, works offline).
      final local = await _localAccounts();
      final match = local.where((a) => a.id == accountId).toList();
      if (match.isNotEmpty) {
        return match.first.pin == pin ? match.first : null;
      }

      // Fallback to Supabase if not found locally.
      if (SupabaseService.isConfigured) {
        final data = await _supabase.client
            .from('child_accounts')
            .select()
            .eq('id', accountId)
            .limit(1);
        final accounts = (data as List<dynamic>)
            .map((e) => ChildAccount.fromJson(e as Map<String, dynamic>))
            .toList();
        if (accounts.isNotEmpty && accounts.first.pin == pin) {
          return accounts.first;
        }
      }
    } catch (_) {}
    return null;
  }

  /// Sets the currently active child account in session.
  Future<void> setActiveChildAccount(ChildAccount account) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kActiveChildKey, account.id);
    await prefs.setString('active_child_name', account.accountName);
    await prefs.setString('active_child_avatar', account.avatarUrl ?? '');
    await prefs.setInt('active_child_age', account.ageYears);
    await prefs.setBool('child_logged_in', true);
    await prefs.setString('user_role', 'child');
  }

  /// Gets the currently active child account id.
  Future<String?> getActiveChildAccountId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kActiveChildKey);
  }

  /// Gets active child name.
  Future<String> getActiveChildName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('active_child_name') ?? 'Child';
  }

  /// Gets active child age (0 = not set).
  Future<int> getActiveChildAge() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('active_child_age') ?? 0;
  }

  /// Gets active child avatar url.
  Future<String?> getActiveChildAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getString('active_child_avatar');
    return (v == null || v.isEmpty) ? null : v;
  }

  /// Clears the active child session.
  Future<void> clearActiveChild() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kActiveChildKey);
    await prefs.remove('active_child_name');
    await prefs.remove('active_child_avatar');
  }

  // -------- Account Requests (children request accounts) --------

  static const _kRequestsKey = 'child_account_requests';

  Future<List<Map<String, dynamic>>> getPendingRequests() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kRequestsKey);
    if (raw == null) return [];
    return List<Map<String, dynamic>>.from(
        (jsonDecode(raw) as List).map((e) => Map<String, dynamic>.from(e)));
  }

  Future<void> submitAccountRequest({
    required String name,
    required int ageYears,
    String note = '',
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = await getPendingRequests();
    existing.add({
      'id': const Uuid().v4(),
      'name': name,
      'age_years': ageYears,
      'note': note,
      'submitted_at': DateTime.now().toIso8601String(),
      'status': 'pending',
    });
    await prefs.setString(_kRequestsKey, jsonEncode(existing));
  }

  /// Admin/parent approves a pending request and creates the account.
  Future<void> approveRequest(String requestId, String pin) async {
    final requests = await getPendingRequests();
    final idx = requests.indexWhere((r) => r['id'] == requestId);
    if (idx == -1) return;
    final req = requests[idx];
    await createAccount(
      parentUserId: 'approved',
      accountName: req['name'] as String,
      pin: pin,
      ageYears: req['age_years'] as int? ?? 0,
    );
    requests.removeAt(idx);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kRequestsKey, jsonEncode(requests));
  }

  Future<void> deleteRequest(String requestId) async {
    final requests = await getPendingRequests();
    requests.removeWhere((r) => r['id'] == requestId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kRequestsKey, jsonEncode(requests));
  }

  // -------- Avatar --------

  /// Updates avatar URL for a child account.
  Future<void> updateAvatar(String accountId, String avatarUrl) async {
    final all = await _localAccounts();
    final idx = all.indexWhere((a) => a.id == accountId);
    if (idx != -1) {
      all[idx] = all[idx].copyWith(avatarUrl: avatarUrl);
      await _saveLocal(all);
    }
    try {
      if (SupabaseService.isConfigured) {
        await _supabase.client
            .from('child_accounts')
            .update({'avatar_url': avatarUrl}).eq('id', accountId);
      }
    } catch (_) {}
  }
}
