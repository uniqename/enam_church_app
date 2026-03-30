import '../models/ministry.dart';
import 'supabase_service.dart';

class MinistryService {
  static final MinistryService _instance = MinistryService._internal();
  factory MinistryService() => _instance;
  MinistryService._internal();

  final _supabase = SupabaseService();

  Future<List<Ministry>> getAllMinistries() async {
    try {
      final data = await _supabase.getAll('ministries');
      return data.map((json) => Ministry.fromSupabase(json)).toList();
    } catch (e) {
      print('❌ Failed to fetch ministries: $e');
      return [];
    }
  }
}
