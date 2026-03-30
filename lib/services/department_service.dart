import '../models/department.dart';
import 'supabase_service.dart';

class DepartmentService {
  static final DepartmentService _instance = DepartmentService._internal();
  factory DepartmentService() => _instance;
  DepartmentService._internal();

  final _supabase = SupabaseService();

  Future<List<Department>> getAllDepartments() async {
    try {
      final data = await _supabase.getAll('departments');
      return data.map((json) => Department.fromSupabase(json)).toList();
    } catch (e) {
      print('❌ Failed to fetch departments: $e');
      return [];
    }
  }
}
