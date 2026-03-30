import 'package:flutter/material.dart';
import '../../models/child_game.dart';
import '../../services/child_content_service.dart';
import '../../utils/colors.dart';
import 'games/bible_quiz_game.dart';
import 'games/game_data.dart';

class ChildGamesScreen extends StatefulWidget {
  const ChildGamesScreen({super.key});

  @override
  State<ChildGamesScreen> createState() => _ChildGamesScreenState();
}

class _ChildGamesScreenState extends State<ChildGamesScreen> {
  final _contentService = ChildContentService();
  List<ChildGame> _games = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final games = await _contentService.getAllGames();
      setState(() {
        _games = games;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load games: $e')),
        );
      }
    }
  }

  void _launchGame(ChildGame game) {
    final questions = GameData.getQuestionsForGame(game.id);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BibleQuizGame(
          gameTitle: game.title,
          questions: questions,
        ),
      ),
    ).then((_) => _loadData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bible Games'),
        backgroundColor: AppColors.childGreen,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.childGreen.withValues(alpha: 0.3),
                          AppColors.childBlue.withValues(alpha: 0.3),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.games, size: 64, color: AppColors.childGreen),
                        SizedBox(height: 16),
                        Text(
                          'Bible Adventure Games!',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.childGreen,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Play fun games and learn about God!',
                          style: TextStyle(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _games.isEmpty
                      ? const Center(child: Text('No games available yet'))
                      : GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 0.85,
                          ),
                          itemCount: _games.length,
                          itemBuilder: (context, index) {
                            final game = _games[index];
                            final color = game.difficulty == 'Easy'
                                ? AppColors.childGreen
                                : game.difficulty == 'Medium'
                                    ? AppColors.childYellow
                                    : AppColors.childOrange;

                            return Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () => _launchGame(game),
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        color,
                                        color.withValues(alpha: 0.7)
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      children: [
                                        if (game.completed)
                                          const Align(
                                            alignment: Alignment.topRight,
                                            child: Icon(
                                              Icons.check_circle,
                                              color: Colors.white,
                                            ),
                                          ),
                                        const Icon(Icons.games,
                                            size: 48, color: Colors.white),
                                        const SizedBox(height: 12),
                                        Text(
                                          game.title,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const Spacer(),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white
                                                .withValues(alpha: 0.3),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            game.difficulty,
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.white),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        ElevatedButton(
                                          onPressed: () => _launchGame(game),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.white,
                                            foregroundColor: color,
                                            minimumSize:
                                                const Size(double.infinity, 36),
                                          ),
                                          child: Text(game.completed
                                              ? 'Play Again!'
                                              : 'Start Game!'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
    );
  }
}
