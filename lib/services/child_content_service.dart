import '../models/child_game.dart';
import '../models/child_lesson.dart';
import '../models/child_sermon.dart';
import 'supabase_service.dart';

// ── Built-in starter content — always available, no Supabase needed ──────────

const _defaultGames = [
  ChildGame(id: 'creation', title: 'Creation Story Quiz',    description: 'Learn how God created the world in 6 days!',         difficulty: 'Easy',   completed: false),
  ChildGame(id: 'noah',     title: 'Noah & the Ark',          description: "Test your knowledge about Noah's great adventure!",   difficulty: 'Easy',   completed: false),
  ChildGame(id: 'david',    title: 'David & Goliath',         description: 'How much do you know about brave young David?',       difficulty: 'Medium', completed: false),
  ChildGame(id: 'jesus',    title: 'The Life of Jesus',       description: 'Explore miracles and teachings of Jesus Christ!',     difficulty: 'Medium', completed: false),
  ChildGame(id: 'moses',    title: 'Moses & the Exodus',      description: "Follow Moses as God leads His people to freedom!",    difficulty: 'Medium', completed: false),
  ChildGame(id: 'esther',   title: "Queen Esther's Courage",  description: 'Discover how Esther saved her people with courage!',  difficulty: 'Hard',   completed: false),
];

List<ChildLesson> get _defaultLessons => [
  ChildLesson(id: 'lesson-1', title: 'God Creates the World',        content: 'In the beginning, God created the heavens and the earth.\n\nOn Day 1, He made light. On Day 2, the sky. On Day 3, dry land and plants. On Day 4, the sun, moon and stars. On Day 5, fish and birds. On Day 6, animals and people — Adam and Eve.\n\nOn Day 7, God rested and called it holy. Everything God made was very good!\n\n📖 Genesis 1',       duration: '5 min', ageRange: '5-10', completed: false),
  ChildLesson(id: 'lesson-2', title: 'Noah Builds the Ark',          content: "Noah loved God when everyone around him did not. God asked Noah to build a giant boat called an ark and bring two of every animal inside.\n\nIt rained for 40 days and 40 nights, but Noah and his family were safe. When the flood ended, God put a rainbow in the sky as a promise to never flood the whole earth again.\n\nGod always keeps His promises!\n\n📖 Genesis 6–9",  duration: '5 min', ageRange: '5-12', completed: false),
  ChildLesson(id: 'lesson-3', title: 'David and Goliath',            content: "David was a young shepherd boy who trusted God completely. A giant soldier named Goliath was scaring all of Israel's army.\n\nBut David said, 'God will help me!' He picked up five smooth stones, used his sling, and — with one stone — defeated Goliath!\n\nGod uses people who trust Him, no matter how small they seem.\n\n📖 1 Samuel 17",                                duration: '6 min', ageRange: '6-12', completed: false),
  ChildLesson(id: 'lesson-4', title: 'Jesus Feeds 5,000 People',     content: "A large crowd followed Jesus all day to hear Him teach. Evening came and everyone was hungry. A small boy gave Jesus his lunch — just 5 loaves of bread and 2 fish.\n\nJesus thanked God, broke the bread, and His disciples gave food to over 5,000 people. Everyone ate until they were full, and there were 12 baskets of leftovers!\n\nNothing is too hard for God!\n\n📖 John 6:1–14",  duration: '5 min', ageRange: '5-12', completed: false),
  ChildLesson(id: 'lesson-5', title: 'Moses and the Red Sea',        content: "Moses led the people of Israel out of Egypt where they had been slaves. Pharaoh's army chased them to the edge of the Red Sea. The people were afraid.\n\nBut God told Moses to raise his staff over the water. God parted the sea! The Israelites walked through on dry ground. When the army followed, the waters came back together.\n\nGod always makes a way for His people!\n\n📖 Exodus 14",   duration: '6 min', ageRange: '6-12', completed: false),
  ChildLesson(id: 'lesson-6', title: "Queen Esther Saves Her People", content: "Esther was a young Jewish girl who became queen of Persia. A wicked man named Haman made a plan to hurt all the Jewish people.\n\nEsther's cousin Mordecai told her, 'Maybe God made you queen for just this moment!' Even though it was scary, Esther went to the king and spoke up bravely. The king listened, Haman's plan was stopped, and God's people were saved.\n\nGod can use you to do great things!\n\n📖 Book of Esther",   duration: '7 min', ageRange: '7-12', completed: false),
];

List<ChildSermon> get _defaultSermons => [
  ChildSermon(id: 'cs-1', title: 'The Story of Creation for Kids',   speaker: 'Kids Ministry',  date: DateTime(2024, 1,  1), duration: '4:30', views: 0, videoUrl: 'https://www.youtube.com/watch?v=PiCd4hJiOKE'),
  ChildSermon(id: 'cs-2', title: 'Noah and the Ark — Kids Bible Story', speaker: 'Kids Ministry', date: DateTime(2024, 1, 8),  duration: '5:00', views: 0, videoUrl: 'https://www.youtube.com/watch?v=7dGEbWVYKZk'),
  ChildSermon(id: 'cs-3', title: 'David and Goliath for Children',   speaker: 'Kids Ministry',  date: DateTime(2024, 1, 15), duration: '5:45', views: 0, videoUrl: 'https://www.youtube.com/watch?v=mxPn4hE4Bfw'),
  ChildSermon(id: 'cs-4', title: 'Jesus Loves Me — Kids Worship',    speaker: 'Kids Worship',   date: DateTime(2024, 1, 22), duration: '3:20', views: 0, videoUrl: 'https://www.youtube.com/watch?v=ZJPuFsEoQ-8'),
  ChildSermon(id: 'cs-5', title: 'Moses and the Red Sea',            speaker: 'Kids Ministry',  date: DateTime(2024, 1, 29), duration: '6:10', views: 0, videoUrl: 'https://www.youtube.com/watch?v=BSEqI2rJIcs'),
  ChildSermon(id: 'cs-6', title: "The Lord's Prayer for Kids",       speaker: 'Kids Ministry',  date: DateTime(2024, 2,  5), duration: '4:00', views: 0, videoUrl: 'https://www.youtube.com/watch?v=lLpJy1tKBqo'),
];

class ChildContentService {
  static final ChildContentService _instance = ChildContentService._internal();
  factory ChildContentService() => _instance;
  ChildContentService._internal();

  final _supabase = SupabaseService();

  // Games
  Future<List<ChildGame>> getAllGames() async {
    try {
      final data = await _supabase.getAll('child_games');
      if (data.isNotEmpty) {
        return data.map((json) => ChildGame.fromSupabase(json)).toList();
      }
    } catch (e) {
      print('❌ Failed to fetch games: $e');
    }
    return _defaultGames.toList();
  }

  Future<void> updateGameProgress(String gameId, String childId, bool completed) async {
    try {
      await _supabase.client.from('child_game_progress').upsert({
        'game_id': gameId,
        'child_id': childId,
        'completed': completed,
        'completed_at': completed ? DateTime.now().toIso8601String() : null,
      });
      print('✅ Game progress updated');
    } catch (e) {
      print('❌ Failed to update game progress: $e');
      rethrow;
    }
  }

  // Lessons
  Future<List<ChildLesson>> getAllLessons() async {
    try {
      final data = await _supabase.getAll('child_lessons');
      if (data.isNotEmpty) {
        return data.map((json) => ChildLesson.fromSupabase(json)).toList();
      }
    } catch (e) {
      print('❌ Failed to fetch lessons: $e');
    }
    return _defaultLessons;
  }

  Future<void> updateLessonProgress(String lessonId, String childId, bool completed) async {
    try {
      await _supabase.client.from('child_lesson_progress').upsert({
        'lesson_id': lessonId,
        'child_id': childId,
        'completed': completed,
        'completed_at': completed ? DateTime.now().toIso8601String() : null,
      });
      print('✅ Lesson progress updated');
    } catch (e) {
      print('❌ Failed to update lesson progress: $e');
      rethrow;
    }
  }

  // Sermons
  Future<List<ChildSermon>> getAllSermons() async {
    try {
      final data = await _supabase.getAll('child_sermons');
      if (data.isNotEmpty) {
        return data.map((json) => ChildSermon.fromSupabase(json)).toList();
      }
    } catch (e) {
      print('❌ Failed to fetch sermons: $e');
    }
    return _defaultSermons;
  }

  Future<void> incrementSermonViews(String sermonId) async {
    try {
      await _supabase.client.rpc('increment_sermon_views', params: {'sermon_id': sermonId});
      print('✅ Sermon views incremented');
    } catch (e) {
      print('❌ Failed to increment views: $e');
    }
  }

  Future<void> updateLesson(ChildLesson lesson) async {
    try {
      await _supabase.update('child_lessons', lesson.id, lesson.toSupabase());
      print('✅ Lesson updated');
    } catch (e) {
      print('❌ Failed to update lesson: $e');
      rethrow;
    }
  }
}
