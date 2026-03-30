import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/finance.dart';
import 'supabase_service.dart';
import 'package:uuid/uuid.dart';

class FinanceService {
  static final FinanceService _instance = FinanceService._internal();
  factory FinanceService() => _instance;
  FinanceService._internal();

  final _supabase = SupabaseService();
  final _uuid = const Uuid();

  static const _kFinancesKey = 'local_finances';

  Future<List<Finance>> _getLocalFinances() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kFinancesKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((e) => Finance.fromSupabase(e as Map<String, dynamic>)).toList();
  }

  Future<void> _saveLocalFinances(List<Finance> finances) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _kFinancesKey, jsonEncode(finances.map((f) => f.toSupabase()).toList()));
  }

  Future<List<Finance>> getAllFinances() async {
    if (SupabaseService.isConfigured) {
      try {
        final data = await _supabase.query(
          'finances',
          orderBy: 'date',
          ascending: false,
        );
        if (data.isNotEmpty) {
          return data.map((json) => Finance.fromSupabase(json)).toList();
        }
      } catch (e) {
        print('⚠️ Supabase unavailable, using local finances: $e');
      }
    }
    final local = await _getLocalFinances();
    return local..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> addFinance(Finance finance) async {
    final id = _uuid.v4();
    final withId = Finance(
      id: id,
      type: finance.type,
      amount: finance.amount,
      memberName: finance.memberName,
      date: finance.date,
      method: finance.method,
      status: finance.status,
      department: finance.department,
    );
    if (SupabaseService.isConfigured) {
      try {
        await _supabase.insert('finances', withId.toSupabase());
        print('✅ Finance record added');
        return;
      } catch (e) {
        print('⚠️ Supabase unavailable, saving finance locally: $e');
      }
    }
    final finances = await _getLocalFinances();
    finances.insert(0, withId);
    await _saveLocalFinances(finances);
    print('✅ Finance record saved locally');
  }

  Future<void> updateFinance(Finance finance) async {
    if (SupabaseService.isConfigured) {
      try {
        await _supabase.update('finances', finance.id, finance.toSupabase());
        print('✅ Finance record updated');
        return;
      } catch (e) {
        print('⚠️ Supabase unavailable for updateFinance: $e');
      }
    }
    final finances = await _getLocalFinances();
    final index = finances.indexWhere((f) => f.id == finance.id);
    if (index >= 0) {
      finances[index] = finance;
      await _saveLocalFinances(finances);
    }
  }

  Future<void> deleteFinance(String id) async {
    if (SupabaseService.isConfigured) {
      try {
        await _supabase.delete('finances', id);
        print('✅ Finance record deleted');
        return;
      } catch (e) {
        print('⚠️ Supabase unavailable for deleteFinance: $e');
      }
    }
    final finances = await _getLocalFinances();
    finances.removeWhere((f) => f.id == id);
    await _saveLocalFinances(finances);
  }

  /// Sum of ALL finance records regardless of type.
  Future<double> getTotal() async {
    final all = await getAllFinances();
    return all.fold<double>(0.0, (sum, f) => sum + f.amount);
  }

  Future<double> getTotalByType(String type) async {
    final all = await getAllFinances();
    return all
        .where((f) => f.type == type)
        .fold<double>(0.0, (sum, f) => sum + f.amount);
  }
}
