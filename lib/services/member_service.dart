import '../models/member.dart';
import 'local_data_service.dart';
import 'supabase_service.dart';
import 'package:uuid/uuid.dart';

class MemberService {
  static final MemberService _instance = MemberService._internal();
  factory MemberService() => _instance;
  MemberService._internal();

  final _supabase = SupabaseService();
  final _uuid = const Uuid();

  Future<List<Member>> getAllMembers() async {
    try {
      final data = await _supabase.getAll('members');
      if (data.isNotEmpty) {
        return data.map((json) => Member.fromSupabase(json)).toList();
      }
    } catch (e) {
      print('❌ Failed to fetch members from Supabase: $e');
    }
    // Supabase empty or unavailable — fall back to built-in FK member roster
    return LocalDataService().getMembers();
  }

  Future<Member?> getMemberById(String id) async {
    try {
      final data = await _supabase.getById('members', id);
      return data != null ? Member.fromSupabase(data) : null;
    } catch (e) {
      print('❌ Failed to fetch member: $e');
      return null;
    }
  }

  Future<void> addMember(Member member) async {
    try {
      final memberData = member.toSupabase();
      memberData['id'] = _uuid.v4();
      await _supabase.insert('members', memberData);
      print('✅ Member added: ${member.name}');
    } catch (e) {
      print('❌ Failed to add member: $e');
      rethrow;
    }
  }

  Future<void> updateMember(Member member) async {
    try {
      await _supabase.update('members', member.id, member.toSupabase());
      print('✅ Member updated: ${member.name}');
    } catch (e) {
      print('❌ Failed to update member: $e');
      rethrow;
    }
  }

  Future<void> deleteMember(String id) async {
    try {
      await _supabase.delete('members', id);
      print('✅ Member deleted: $id');
    } catch (e) {
      print('❌ Failed to delete member: $e');
      rethrow;
    }
  }

  Future<List<Member>> getMembersByDepartment(String department) async {
    try {
      final data = await _supabase.query(
        'members',
        column: 'department',
        value: department,
      );
      return data.map((json) => Member.fromSupabase(json)).toList();
    } catch (e) {
      print('❌ Failed to fetch members by department: $e');
      return [];
    }
  }

  Future<List<Member>> getMembersByRole(String role) async {
    try {
      final data = await _supabase.query(
        'members',
        column: 'role',
        value: role,
      );
      return data.map((json) => Member.fromSupabase(json)).toList();
    } catch (e) {
      print('❌ Failed to fetch members by role: $e');
      return [];
    }
  }
}
