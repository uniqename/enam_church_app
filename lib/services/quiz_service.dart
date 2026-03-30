import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/quiz_model.dart';
import 'supabase_service.dart';

class QuizService {
  static final QuizService _instance = QuizService._internal();
  factory QuizService() => _instance;
  QuizService._internal();

  final _supabase = SupabaseService();
  final _uuid = const Uuid();

  static const String _localKey = 'local_quizzes';
  static const String _scoresKey = 'quiz_scores';

  // ── Built-in starter quizzes ──────────────────────────────────────────────
  static final List<QuizModel> _starterQuizzes = [
    QuizModel(
      id: 'starter-bible-basics',
      title: 'Bible Basics',
      description: 'Test your knowledge of fundamental Bible stories and verses.',
      category: 'Bible',
      createdBy: 'system',
      createdByName: 'Faith Klinik',
      createdAt: DateTime(2026, 1, 1),
      questions: const [
        QuizQuestion(
          question: 'How many books are in the Bible?',
          options: ['60', '66', '72', '80'],
          correctIndex: 1,
          timeLimitSeconds: 20,
        ),
        QuizQuestion(
          question: 'Who built the ark?',
          options: ['Moses', 'Abraham', 'Noah', 'David'],
          correctIndex: 2,
          timeLimitSeconds: 15,
        ),
        QuizQuestion(
          question: 'What is the first book of the Bible?',
          options: ['Exodus', 'Psalms', 'Matthew', 'Genesis'],
          correctIndex: 3,
          timeLimitSeconds: 15,
        ),
        QuizQuestion(
          question: 'How many disciples did Jesus have?',
          options: ['10', '11', '12', '13'],
          correctIndex: 2,
          timeLimitSeconds: 15,
        ),
        QuizQuestion(
          question: 'In which city was Jesus born?',
          options: ['Jerusalem', 'Nazareth', 'Bethlehem', 'Jericho'],
          correctIndex: 2,
          timeLimitSeconds: 20,
        ),
        QuizQuestion(
          question: 'What is the longest book in the Bible?',
          options: ['Genesis', 'Isaiah', 'Psalms', 'Jeremiah'],
          correctIndex: 2,
          timeLimitSeconds: 20,
        ),
      ],
    ),
    QuizModel(
      id: 'starter-old-testament',
      title: 'Old Testament Heroes',
      description: 'How well do you know the great heroes of the Old Testament?',
      category: 'Bible',
      createdBy: 'system',
      createdByName: 'Faith Klinik',
      createdAt: DateTime(2026, 1, 1),
      questions: const [
        QuizQuestion(
          question: 'Who was thrown into the lion\'s den?',
          options: ['Elijah', 'Daniel', 'Jeremiah', 'Isaiah'],
          correctIndex: 1,
          timeLimitSeconds: 20,
        ),
        QuizQuestion(
          question: 'What did David use to defeat Goliath?',
          options: ['A sword', 'An arrow', 'A sling and stone', 'His fists'],
          correctIndex: 2,
          timeLimitSeconds: 20,
        ),
        QuizQuestion(
          question: 'Who was the wisest king in the Bible?',
          options: ['David', 'Saul', 'Solomon', 'Hezekiah'],
          correctIndex: 2,
          timeLimitSeconds: 15,
        ),
        QuizQuestion(
          question: 'How many days was Jonah in the belly of the fish?',
          options: ['1', '2', '3', '7'],
          correctIndex: 2,
          timeLimitSeconds: 20,
        ),
        QuizQuestion(
          question: 'Who led the Israelites out of Egypt?',
          options: ['Abraham', 'Moses', 'Joshua', 'Aaron'],
          correctIndex: 1,
          timeLimitSeconds: 15,
        ),
      ],
    ),
    QuizModel(
      id: 'starter-new-testament',
      title: 'New Testament Challenge',
      description: 'Test your knowledge of the Gospels and New Testament events.',
      category: 'Bible',
      createdBy: 'system',
      createdByName: 'Faith Klinik',
      createdAt: DateTime(2026, 1, 1),
      questions: const [
        QuizQuestion(
          question: 'Who wrote most of the New Testament letters?',
          options: ['Peter', 'John', 'Paul', 'James'],
          correctIndex: 2,
          timeLimitSeconds: 20,
        ),
        QuizQuestion(
          question: 'What miracle did Jesus perform at the wedding in Cana?',
          options: ['Healed the blind', 'Turned water into wine', 'Fed 5000 people', 'Walked on water'],
          correctIndex: 1,
          timeLimitSeconds: 20,
        ),
        QuizQuestion(
          question: 'How many days after His death did Jesus rise?',
          options: ['1', '2', '3', '7'],
          correctIndex: 2,
          timeLimitSeconds: 15,
        ),
        QuizQuestion(
          question: 'Who baptized Jesus?',
          options: ['Peter', 'John the Baptist', 'James', 'Matthew'],
          correctIndex: 1,
          timeLimitSeconds: 15,
        ),
        QuizQuestion(
          question: 'Which disciple denied Jesus 3 times?',
          options: ['John', 'Thomas', 'Peter', 'Judas'],
          correctIndex: 2,
          timeLimitSeconds: 20,
        ),
        QuizQuestion(
          question: 'What did the wise men follow to find Jesus?',
          options: ['A cloud', 'An angel', 'A star', 'A dove'],
          correctIndex: 2,
          timeLimitSeconds: 15,
        ),
      ],
    ),
    QuizModel(
      id: 'starter-faith-klinik',
      title: 'Know Your Church',
      description: 'How well do you know Faith Klinik Ministries?',
      category: 'Church',
      createdBy: 'system',
      createdByName: 'Faith Klinik',
      createdAt: DateTime(2026, 1, 1),
      questions: const [
        QuizQuestion(
          question: 'What day is the main Sunday service held?',
          options: ['Friday', 'Saturday', 'Sunday', 'Wednesday'],
          correctIndex: 2,
          timeLimitSeconds: 15,
        ),
        QuizQuestion(
          question: 'Which of these is a ministry at Faith Klinik?',
          options: ['Finance Ministry', 'Prayer Ministry', 'Sports Ministry', 'Fashion Ministry'],
          correctIndex: 1,
          timeLimitSeconds: 20,
        ),
        QuizQuestion(
          question: 'What color represents Faith Klinik\'s brand?',
          options: ['Blue', 'Red', 'Purple', 'Green'],
          correctIndex: 2,
          timeLimitSeconds: 15,
        ),
        QuizQuestion(
          question: 'Faith Klinik has a children\'s ministry for children aged:',
          options: ['0-1', '2-12', '13-17', '18+'],
          correctIndex: 1,
          timeLimitSeconds: 20,
        ),
        QuizQuestion(
          question: 'What feature in the app lets you give to the church?',
          options: ['Events', 'Sermons', 'Giving', 'Groups'],
          correctIndex: 2,
          timeLimitSeconds: 15,
        ),
      ],
    ),
    QuizModel(
      id: 'starter-children-fun',
      title: 'Children Bible Fun',
      description: 'Super easy Bible questions for young ones!',
      category: 'Children',
      createdBy: 'system',
      createdByName: 'Faith Klinik',
      createdAt: DateTime(2026, 1, 1),
      questions: const [
        QuizQuestion(
          question: 'What did God create on the first day?',
          options: ['Animals', 'Light', 'Plants', 'Oceans'],
          correctIndex: 1,
          timeLimitSeconds: 20,
        ),
        QuizQuestion(
          question: 'How many days did God take to create the world?',
          options: ['3', '5', '6', '7'],
          correctIndex: 2,
          timeLimitSeconds: 20,
        ),
        QuizQuestion(
          question: 'What did Moses part with his staff?',
          options: ['A river', 'The sea', 'The clouds', 'A mountain'],
          correctIndex: 1,
          timeLimitSeconds: 20,
        ),
        QuizQuestion(
          question: 'Jesus fed 5000 people with how many loaves of bread?',
          options: ['2', '5', '10', '12'],
          correctIndex: 1,
          timeLimitSeconds: 20,
        ),
        QuizQuestion(
          question: 'Who was Jesus\' mother?',
          options: ['Martha', 'Mary', 'Elizabeth', 'Ruth'],
          correctIndex: 1,
          timeLimitSeconds: 15,
        ),
      ],
    ),
  ];

  // ── Public API ────────────────────────────────────────────────────────────

  String generateId() => _uuid.v4();

  Future<List<QuizModel>> getAllQuizzes() async {
    List<QuizModel> custom = await _getCustomQuizzes();
    return [...custom, ..._starterQuizzes];
  }

  Future<void> saveQuiz(QuizModel quiz) async {
    if (SupabaseService.isConfigured) {
      try {
        await _supabase.insert('quizzes', quiz.toSupabase());
        return;
      } catch (_) {}
    }
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_localKey);
    List<Map<String, dynamic>> list = [];
    if (raw != null) {
      list = List<Map<String, dynamic>>.from(jsonDecode(raw) as List);
    }
    list.removeWhere((q) => q['id'] == quiz.id);
    list.insert(0, quiz.toSupabase());
    await prefs.setString(_localKey, jsonEncode(list));
  }

  Future<void> updateQuiz(QuizModel quiz) async {
    if (SupabaseService.isConfigured) {
      try {
        await _supabase.update('quizzes', quiz.id, quiz.toSupabase());
        return;
      } catch (_) {}
    }
    await saveQuiz(quiz); // local upsert
  }

  Future<void> deleteQuiz(String quizId) async {
    if (SupabaseService.isConfigured) {
      try {
        await _supabase.delete('quizzes', quizId);
        return;
      } catch (_) {}
    }
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_localKey);
    if (raw == null) return;
    List<Map<String, dynamic>> list =
        List<Map<String, dynamic>>.from(jsonDecode(raw) as List);
    list.removeWhere((q) => q['id'] == quizId);
    await prefs.setString(_localKey, jsonEncode(list));
  }

  Future<void> saveScore({
    required String quizId,
    required String userId,
    required String userName,
    required int score,
    required int totalQuestions,
  }) async {
    final entry = {
      'id': _uuid.v4(),
      'quiz_id': quizId,
      'user_id': userId,
      'user_name': userName,
      'score': score,
      'total': totalQuestions,
      'played_at': DateTime.now().toIso8601String(),
    };
    if (SupabaseService.isConfigured) {
      try {
        await _supabase.insert('quiz_scores', entry);
        return;
      } catch (_) {}
    }
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_scoresKey);
    List<Map<String, dynamic>> list = [];
    if (raw != null) {
      list = List<Map<String, dynamic>>.from(jsonDecode(raw) as List);
    }
    list.add(entry);
    await prefs.setString(_scoresKey, jsonEncode(list));
  }

  Future<List<Map<String, dynamic>>> getLeaderboard(String quizId) async {
    if (SupabaseService.isConfigured) {
      try {
        final data = await _supabase.query('quiz_scores',
            column: 'quiz_id', value: quizId, orderBy: 'score', ascending: false);
        return data.take(10).toList();
      } catch (_) {}
    }
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_scoresKey);
    if (raw == null) return [];
    List<Map<String, dynamic>> list =
        List<Map<String, dynamic>>.from(jsonDecode(raw) as List);
    list = list.where((e) => e['quiz_id'] == quizId).toList();
    list.sort((a, b) => (b['score'] as int).compareTo(a['score'] as int));
    return list.take(10).toList();
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  Future<List<QuizModel>> _getCustomQuizzes() async {
    if (SupabaseService.isConfigured) {
      try {
        final data = await _supabase.query('quizzes',
            orderBy: 'created_at', ascending: false);
        if (data.isNotEmpty) {
          return data.map((json) => QuizModel.fromSupabase(json)).toList();
        }
      } catch (_) {}
    }
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_localKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list
        .map((e) => QuizModel.fromSupabase(e as Map<String, dynamic>))
        .toList();
  }
}
