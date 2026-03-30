import 'package:flutter/material.dart';
import '../../models/quiz_model.dart';
import '../../services/quiz_service.dart';
import '../../services/auth_service.dart';
import '../../utils/colors.dart';
import 'quiz_play_screen.dart';
import 'quiz_builder_screen.dart';

class QuizHomeScreen extends StatefulWidget {
  const QuizHomeScreen({super.key});

  @override
  State<QuizHomeScreen> createState() => _QuizHomeScreenState();
}

class _QuizHomeScreenState extends State<QuizHomeScreen> {
  final _quizService = QuizService();
  final _authService = AuthService();

  List<QuizModel> _quizzes = [];
  bool _isLoading = true;
  String? _userId;
  String? _userRole;

  static const _categoryColors = {
    'Bible': Color(0xFF7B1FA2),
    'Church': Color(0xFF1565C0),
    'Children': Color(0xFF2E7D32),
    'General': Color(0xFFE65100),
  };

  static const _categoryIcons = {
    'Bible': Icons.menu_book,
    'Church': Icons.church,
    'Children': Icons.child_care,
    'General': Icons.quiz,
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final quizzes = await _quizService.getAllQuizzes();
    final userId = await _authService.getCurrentUserId();
    final role = await _authService.getUserRole();
    if (mounted) {
      setState(() {
        _quizzes = quizzes;
        _userId = userId;
        _userRole = role;
        _isLoading = false;
      });
    }
  }

  bool get _canCreate {
    final r = _userRole?.toLowerCase() ?? '';
    return r == 'admin' || r == 'pastor' || r == 'department_head' || r == 'media_team';
  }

  bool _canEdit(QuizModel quiz) {
    if (quiz.isSystem) return false;
    final r = _userRole?.toLowerCase() ?? '';
    return quiz.createdBy == _userId ||
        r == 'admin' ||
        r == 'pastor';
  }

  Color _colorFor(String category) =>
      _categoryColors[category] ?? AppColors.purple;

  IconData _iconFor(String category) =>
      _categoryIcons[category] ?? Icons.quiz;

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1A0030),
      appBar: AppBar(
        title: const Text('Church Quiz'),
        backgroundColor: const Color(0xFF2D0050),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _load,
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader()),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => _buildQuizCard(_quizzes[i]),
                childCount: _quizzes.length,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _canCreate
          ? FloatingActionButton.extended(
              onPressed: _createQuiz,
              backgroundColor: const Color(0xFF9C27B0),
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('Create Quiz'),
            )
          : null,
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4A148C), Color(0xFF880E4F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          const Text('🎮', style: TextStyle(fontSize: 40)),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Church Quiz',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Fun for the whole congregation!',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizCard(QuizModel quiz) {
    final color = _colorFor(quiz.category);
    final icon = _iconFor(quiz.category);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2A1040),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        quiz.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              quiz.category,
                              style: TextStyle(
                                  fontSize: 10,
                                  color: color,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${quiz.questionCount} questions',
                            style: const TextStyle(
                                fontSize: 12, color: Colors.white54),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (_canEdit(quiz))
                  IconButton(
                    icon: const Icon(Icons.edit_outlined,
                        color: Colors.white38, size: 20),
                    onPressed: () => _editQuiz(quiz),
                    tooltip: 'Edit quiz',
                  ),
              ],
            ),
            if (quiz.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                quiz.description,
                style:
                    const TextStyle(fontSize: 12, color: Colors.white60),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 4),
            Text(
              'By ${quiz.createdByName}',
              style:
                  const TextStyle(fontSize: 11, color: Colors.white38),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _playQuiz(quiz),
                    icon: const Icon(Icons.play_arrow, size: 18),
                    label: const Text('Play Now'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () => _showLeaderboard(quiz),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: color,
                    side: BorderSide(color: color.withValues(alpha: 0.5)),
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Icon(Icons.leaderboard, size: 18),
                ),
                if (_canEdit(quiz)) ...[
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () => _confirmDelete(quiz),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red[300],
                      side: BorderSide(
                          color: Colors.red.withValues(alpha: 0.4)),
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Icon(Icons.delete_outline, size: 18),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _playQuiz(QuizModel quiz) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuizPlayScreen(
          quiz: quiz,
          userId: _userId ?? 'guest',
          userName: 'Player',
        ),
      ),
    );
  }

  void _editQuiz(QuizModel quiz) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuizBuilderScreen(existing: quiz),
      ),
    );
    _load();
  }

  void _createQuiz() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuizBuilderScreen(
          creatorId: _userId ?? 'unknown',
          creatorName: 'Admin',
        ),
      ),
    );
    _load();
  }

  void _showLeaderboard(QuizModel quiz) async {
    final scores = await _quizService.getLeaderboard(quiz.id);
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A0030),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _LeaderboardSheet(quiz: quiz, scores: scores),
    );
  }

  void _confirmDelete(QuizModel quiz) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Quiz'),
        content: Text('Delete "${quiz.title}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _quizService.deleteQuiz(quiz.id);
              _load();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _LeaderboardSheet extends StatelessWidget {
  final QuizModel quiz;
  final List<Map<String, dynamic>> scores;

  const _LeaderboardSheet({required this.quiz, required this.scores});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.leaderboard, color: Color(0xFFFFC107)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${quiz.title} — Leaderboard',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (scores.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Text('No scores yet. Be the first to play!',
                  style: TextStyle(color: Colors.white54)),
            )
          else
            ...scores.asMap().entries.map((entry) {
              final i = entry.key;
              final s = entry.value;
              final medal = i == 0
                  ? '🥇'
                  : i == 1
                      ? '🥈'
                      : i == 2
                          ? '🥉'
                          : '${i + 1}.';
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    SizedBox(
                      width: 32,
                      child: Text(medal,
                          style: const TextStyle(fontSize: 18)),
                    ),
                    Expanded(
                      child: Text(
                        s['user_name'] as String? ?? 'Unknown',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 14),
                      ),
                    ),
                    Text(
                      '${s['score']}/${s['total']} pts',
                      style: const TextStyle(
                          color: Color(0xFFFFC107),
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            }),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
