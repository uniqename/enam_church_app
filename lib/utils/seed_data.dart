/// SeedData — utility to populate the Supabase database with real
/// Faith Klinik Ministries data the first time the app is connected.
/// Call [SeedData.seedAll()] once from the admin settings panel.
library;

import 'package:uuid/uuid.dart';
import '../services/local_data_service.dart';
import '../services/supabase_service.dart';

class SeedData {
  static final _supabase = SupabaseService();

  static const _uuid = Uuid();

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
    await _seedChildGames();
    await _seedChildLessons();
    await _seedChildVideos();

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

  static Future<void> _seedChildGames() async {
    print('🌱 Seeding children\'s bible games...');
    final games = [
      {'id': 'creation',  'title': 'Creation Story Quiz',   'description': 'Learn how God created the world in 6 days!', 'difficulty': 'Easy'},
      {'id': 'noah',      'title': 'Noah & the Ark',         'description': 'Test your knowledge about Noah\'s great adventure!', 'difficulty': 'Easy'},
      {'id': 'david',     'title': 'David & Goliath',        'description': 'How much do you know about brave young David?', 'difficulty': 'Medium'},
      {'id': 'jesus',     'title': 'The Life of Jesus',      'description': 'Explore miracles and teachings of Jesus Christ!', 'difficulty': 'Medium'},
      {'id': 'moses',     'title': 'Moses & the Exodus',     'description': 'Follow Moses as he leads God\'s people to freedom!', 'difficulty': 'Medium'},
      {'id': 'esther',    'title': 'Queen Esther\'s Courage','description': 'Discover how Esther saved her people with courage!', 'difficulty': 'Hard'},
    ];
    for (final g in games) {
      try {
        await _supabase.client.from('child_games').upsert({...g, 'completed': false});
      } catch (e) {
        print('⚠️  Game ${g['title']}: $e');
      }
    }
    print('✅ Children\'s games seeded');
  }

  static Future<void> _seedChildLessons() async {
    print('🌱 Seeding children\'s bible stories...');
    final lessons = [
      {
        'id': _uuid.v4(),
        'title': 'God Creates the World',
        'content': 'In the beginning, God created the heavens and the earth. '
            'On Day 1, He made light. On Day 2, the sky. On Day 3, dry land and plants. '
            'On Day 4, the sun, moon and stars. On Day 5, fish and birds. '
            'On Day 6, animals and people — Adam and Eve. '
            'On Day 7, God rested and called it holy. '
            'Everything God made was very good! (Genesis 1)',
        'duration': '5 min',
        'age_range': '5-10',
      },
      {
        'id': _uuid.v4(),
        'title': 'Noah Builds the Ark',
        'content': 'Noah loved God when everyone around him did not. '
            'God asked Noah to build a giant boat called an ark and bring two of every animal inside. '
            'It rained for 40 days and 40 nights, but Noah and his family were safe. '
            'When the flood ended, God put a rainbow in the sky as a promise to never flood the whole earth again. '
            'God always keeps His promises! (Genesis 6–9)',
        'duration': '5 min',
        'age_range': '5-12',
      },
      {
        'id': _uuid.v4(),
        'title': 'David and Goliath',
        'content': 'David was a young shepherd boy who trusted God completely. '
            'A giant soldier named Goliath was scaring all of Israel\'s army. '
            'But David said, "God will help me!" He picked up five smooth stones, '
            'used his sling, and — with one stone — defeated Goliath! '
            'God uses people who trust Him, no matter how small they seem. (1 Samuel 17)',
        'duration': '6 min',
        'age_range': '6-12',
      },
      {
        'id': _uuid.v4(),
        'title': 'Jesus Feeds 5,000 People',
        'content': 'A large crowd had followed Jesus all day to hear Him teach. '
            'Evening came and everyone was hungry. A small boy gave Jesus his lunch — '
            'just 5 loaves of bread and 2 fish. Jesus thanked God, broke the bread, '
            'and His disciples gave food to over 5,000 people. '
            'Everyone ate until they were full, and there were 12 baskets of leftovers! '
            'Nothing is too hard for God! (John 6:1–14)',
        'duration': '5 min',
        'age_range': '5-12',
      },
      {
        'id': _uuid.v4(),
        'title': 'Moses and the Red Sea',
        'content': 'Moses led the people of Israel out of Egypt where they had been slaves. '
            'Pharaoh\'s army chased them to the edge of the Red Sea. '
            'The people were afraid, but God told Moses to raise his staff over the water. '
            'God parted the sea! The Israelites walked through on dry ground. '
            'When the army followed, the waters came back together. '
            'God always makes a way for His people! (Exodus 14)',
        'duration': '6 min',
        'age_range': '6-12',
      },
      {
        'id': _uuid.v4(),
        'title': 'Queen Esther Saves Her People',
        'content': 'Esther was a young Jewish girl who became queen of Persia. '
            'A wicked man named Haman made a plan to hurt all the Jewish people. '
            'Esther\'s cousin Mordecai told her, "Maybe God made you queen for just this moment!" '
            'Even though it was scary and dangerous, Esther went to the king and spoke up bravely. '
            'The king listened, Haman\'s plan was stopped, and God\'s people were saved. '
            'God can use you to do great things! (Book of Esther)',
        'duration': '7 min',
        'age_range': '7-12',
      },
    ];
    for (final lesson in lessons) {
      try {
        await _supabase.client.from('child_lessons').upsert({...lesson, 'completed': false});
      } catch (e) {
        print('⚠️  Lesson ${lesson['title']}: $e');
      }
    }
    print('✅ Children\'s lessons/stories seeded');
  }

  static Future<void> _seedChildVideos() async {
    print('🌱 Seeding children\'s videos...');
    final now = DateTime.now().toIso8601String();
    final videos = [
      {
        'id': _uuid.v4(),
        'title': 'The Story of Creation for Kids',
        'description': 'A fun, animated retelling of how God created the world in 6 days.',
        'youtube_url': 'https://www.youtube.com/watch?v=PiCd4hJiOKE',
        'video_url': '',
        'thumbnail_url': 'https://img.youtube.com/vi/PiCd4hJiOKE/hqdefault.jpg',
        'category': 'Bible Stories',
        'speaker': 'Kids Ministry',
        'duration': '4:30',
        'views': 0,
        'uploaded_at': now,
        'is_published': true,
        'audience': 'children',
        'uploaded_by': 'admin',
      },
      {
        'id': _uuid.v4(),
        'title': 'Noah and the Ark — Kids Bible Story',
        'description': 'Watch the story of Noah, the ark, and God\'s rainbow promise come alive!',
        'youtube_url': 'https://www.youtube.com/watch?v=7dGEbWVYKZk',
        'video_url': '',
        'thumbnail_url': 'https://img.youtube.com/vi/7dGEbWVYKZk/hqdefault.jpg',
        'category': 'Bible Stories',
        'speaker': 'Kids Ministry',
        'duration': '5:00',
        'views': 0,
        'uploaded_at': now,
        'is_published': true,
        'audience': 'children',
        'uploaded_by': 'admin',
      },
      {
        'id': _uuid.v4(),
        'title': 'David and Goliath for Children',
        'description': 'Brave David trusts God and defeats the giant Goliath with just a stone!',
        'youtube_url': 'https://www.youtube.com/watch?v=mxPn4hE4Bfw',
        'video_url': '',
        'thumbnail_url': 'https://img.youtube.com/vi/mxPn4hE4Bfw/hqdefault.jpg',
        'category': 'Bible Stories',
        'speaker': 'Kids Ministry',
        'duration': '5:45',
        'views': 0,
        'uploaded_at': now,
        'is_published': true,
        'audience': 'children',
        'uploaded_by': 'admin',
      },
      {
        'id': _uuid.v4(),
        'title': 'Jesus Loves Me — Kids Worship Song',
        'description': 'Sing along to this classic children\'s worship song about Jesus\' love!',
        'youtube_url': 'https://www.youtube.com/watch?v=ZJPuFsEoQ-8',
        'video_url': '',
        'thumbnail_url': 'https://img.youtube.com/vi/ZJPuFsEoQ-8/hqdefault.jpg',
        'category': 'Worship',
        'speaker': 'Kids Worship',
        'duration': '3:20',
        'views': 0,
        'uploaded_at': now,
        'is_published': true,
        'audience': 'children',
        'uploaded_by': 'admin',
      },
      {
        'id': _uuid.v4(),
        'title': 'Moses and the Red Sea — Bible Story',
        'description': 'Watch as God parts the Red Sea and leads Moses and the Israelites to safety!',
        'youtube_url': 'https://www.youtube.com/watch?v=BSEqI2rJIcs',
        'video_url': '',
        'thumbnail_url': 'https://img.youtube.com/vi/BSEqI2rJIcs/hqdefault.jpg',
        'category': 'Bible Stories',
        'speaker': 'Kids Ministry',
        'duration': '6:10',
        'views': 0,
        'uploaded_at': now,
        'is_published': true,
        'audience': 'children',
        'uploaded_by': 'admin',
      },
      {
        'id': _uuid.v4(),
        'title': 'The Lord\'s Prayer for Kids',
        'description': 'Learn to pray the Lord\'s Prayer with this fun, easy-to-follow children\'s lesson!',
        'youtube_url': 'https://www.youtube.com/watch?v=lLpJy1tKBqo',
        'video_url': '',
        'thumbnail_url': 'https://img.youtube.com/vi/lLpJy1tKBqo/hqdefault.jpg',
        'category': 'Prayer',
        'speaker': 'Kids Ministry',
        'duration': '4:00',
        'views': 0,
        'uploaded_at': now,
        'is_published': true,
        'audience': 'children',
        'uploaded_by': 'admin',
      },
    ];
    for (final v in videos) {
      try {
        await _supabase.client.from('videos').upsert(v);
      } catch (e) {
        print('⚠️  Video ${v['title']}: $e');
      }
    }
    print('✅ Children\'s videos seeded');
  }
}
