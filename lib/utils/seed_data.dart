/// SeedData — utility to populate the Supabase database with real
/// Faith Klinik Ministries data the first time the app is connected.
/// Call [SeedData.seedAll()] once from the admin settings panel.
library;

import '../services/local_data_service.dart';
import '../services/supabase_service.dart';

class SeedData {
  static final _supabase = SupabaseService();

  /// Seeds all real Faith Klinik data into Supabase.
  /// Safe to run multiple times — uses upsert semantics.
  static Future<void> seedAll() async {
    print('🌱 Starting Faith Klinik Ministries database seeding...');
    final local = LocalDataService();

    await _seedDepartments(local);
    await _seedMinistries(local);
    await _seedMembers(local);
    await _seedStreams(local);
    await _seedAnnouncements(local);
    await _seedEvents(local);

    print('✅ Database seeding completed successfully!');
  }

  static Future<void> _seedDepartments(LocalDataService local) async {
    print('🌱 Seeding departments...');
    for (final dept in local.getDepartments()) {
      try {
        await _supabase.insert('departments', dept.toSupabase());
      } catch (e) {
        print('⚠️  Dept ${dept.name}: $e');
      }
    }
    print('✅ Departments seeded');
  }

  static Future<void> _seedMinistries(LocalDataService local) async {
    print('🌱 Seeding ministries...');
    for (final m in local.getMinistries()) {
      try {
        await _supabase.insert('ministries', m.toSupabase());
      } catch (e) {
        print('⚠️  Ministry ${m.name}: $e');
      }
    }
    print('✅ Ministries seeded');
  }

  static Future<void> _seedMembers(LocalDataService local) async {
    print('🌱 Seeding members...');
    for (final member in local.getMembers()) {
      try {
        await _supabase.insert('members', member.toSupabase());
      } catch (e) {
        print('⚠️  Member ${member.name}: $e');
      }
    }
    print('✅ Members seeded');
  }

  static Future<void> _seedStreams(LocalDataService local) async {
    print('🌱 Seeding live streams...');
    for (final stream in local.getStreams()) {
      try {
        await _supabase.insert('live_streams', stream.toSupabase());
      } catch (e) {
        print('⚠️  Stream ${stream.title}: $e');
      }
    }
    print('✅ Streams seeded');
  }

  static Future<void> _seedAnnouncements(LocalDataService local) async {
    print('🌱 Seeding announcements...');
    for (final a in local.getAnnouncements()) {
      try {
        await _supabase.insert('announcements', a.toSupabase());
      } catch (e) {
        print('⚠️  Announcement: $e');
      }
    }
    print('✅ Announcements seeded');
  }

  static Future<void> _seedEvents(LocalDataService local) async {
    print('🌱 Seeding events...');
    for (final event in local.getEvents()) {
      try {
        await _supabase.insert('events', event.toSupabase());
      } catch (e) {
        print('⚠️  Event ${event.title}: $e');
      }
    }
    print('✅ Events seeded');
  }
}
