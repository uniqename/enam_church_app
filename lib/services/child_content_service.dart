import '../models/child_game.dart';
import '../models/child_lesson.dart';
import '../models/child_sermon.dart';
import 'supabase_service.dart';

class ChildContentService {
  static final ChildContentService _instance = ChildContentService._internal();
  factory ChildContentService() => _instance;
  ChildContentService._internal();

  final _supabase = SupabaseService();

  // Games
  Future<List<ChildGame>> getAllGames() async {
    try {
      final data = await _supabase.getAll('child_games');
      return data.map((json) => ChildGame.fromSupabase(json)).toList();
    } catch (e) {
      print('❌ Failed to fetch games: $e');
      return [];
    }
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
      return data.map((json) => ChildLesson.fromSupabase(json)).toList();
    } catch (e) {
      print('❌ Failed to fetch lessons: $e');
      return [];
    }
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
      return data.map((json) => ChildSermon.fromSupabase(json)).toList();
    } catch (e) {
      print('❌ Failed to fetch sermons: $e');
      return [];
    }
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
