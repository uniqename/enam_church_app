import '../models/membership.dart';
import 'supabase_service.dart';

class MembershipService {
  static final MembershipService _instance = MembershipService._internal();
  factory MembershipService() => _instance;
  MembershipService._internal();

  final _supabase = SupabaseService();

  Future<List<Membership>> getAllMemberships() async {
    try {
      final data = await _supabase.getAll('memberships');
      return data.map((json) => Membership.fromSupabase(json)).toList();
    } catch (e) {
      print('❌ Failed to fetch memberships: $e');
      return [];
    }
  }

  Future<Membership?> getMembershipByUserId(String userId) async {
    try {
      final data = await _supabase.client
          .from('memberships')
          .select()
          .eq('user_id', userId)
          .maybeSingle();
      if (data == null) return null;
      return Membership.fromSupabase(data);
    } catch (e) {
      print('❌ Failed to fetch membership: $e');
      return null;
    }
  }

  Future<void> createMembership(Membership membership) async {
    try {
      await _supabase.create('memberships', membership.toSupabase());
      print('✅ Membership created');
    } catch (e) {
      print('❌ Failed to create membership: $e');
      rethrow;
    }
  }

  Future<void> updateMembership(Membership membership) async {
    try {
      await _supabase.update('memberships', membership.id, membership.toSupabase());
      print('✅ Membership updated');
    } catch (e) {
      print('❌ Failed to update membership: $e');
      rethrow;
    }
  }

  Future<void> deleteMembership(String id) async {
    try {
      await _supabase.delete('memberships', id);
      print('✅ Membership deleted');
    } catch (e) {
      print('❌ Failed to delete membership: $e');
      rethrow;
    }
  }
}
