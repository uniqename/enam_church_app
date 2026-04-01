import 'package:flutter/material.dart';
import '../../../utils/colors.dart';
import 'game_data.dart';

class BibleQuizGame extends StatefulWidget {
  final String gameTitle;
  final List<QuizQuestion> questions;

  const BibleQuizGame({
    super.key,
    required this.gameTitle,
    required this.questions,
  });

  @override
  State<BibleQuizGame> createState() => _BibleQuizGameState();
}

class _BibleQuizGameState extends State<BibleQuizGame> {
  int _currentIndex = 0;
  int _score = 0;
  int? _selectedAnswer;
  bool _answered = false;
  bool _gameOver = false;

  void _selectAnswer(int index) {
    if (_answered) return;
    setState(() {
      _selectedAnswer = index;
      _answered = true;
      if (index == widget.questions[_currentIndex].correctIndex) {
        _score++;
      }
    });
  }

  void _nextQuestion() {
    if (_currentIndex < widget.questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedAnswer = null;
        _answered = false;
      });
    } else {
      setState(() => _gameOver = true);
    }
  }

  Color _optionColor(int index) {
    if (!_answered) return Colors.white;
    final correct = widget.questions[_currentIndex].correctIndex;
    if (index == correct) return Colors.green.shade100;
    if (index == _selectedAnswer) return Colors.red.shade100;
    return Colors.white;
  }

  Color _optionBorder(int index) {
    if (!_answered) return Colors.grey.shade300;
    final correct = widget.questions[_currentIndex].correctIndex;
    if (index == correct) return Colors.green;
    if (index == _selectedAnswer) return Colors.red;
    return Colors.grey.shade300;
  }

  Widget _buildQuestion() {
    final q = widget.questions[_currentIndex];
    final progress = (_currentIndex + 1) / widget.questions.length;

    return Column(
      children: [
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[200],
          color: AppColors.childGreen,
          minHeight: 8,
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Question ${_currentIndex + 1}/${widget.questions.length}',
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.childGreen.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Score: $_score',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.childGreen,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.childBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.childBlue.withValues(alpha: 0.3)),
                ),
                child: Text(
                  q.question,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              ...List.generate(q.options.length, (i) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GestureDetector(
                    onTap: () => _selectAnswer(i),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _optionColor(i),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _optionBorder(i), width: 2),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.childGreen.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                String.fromCharCode(65 + i),
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              q.options[i],
                              style: const TextStyle(fontSize: 16, color: Colors.black87),
                            ),
                          ),
                          if (_answered && i == q.correctIndex)
                            const Icon(Icons.check_circle, color: Colors.green),
                          if (_answered && i == _selectedAnswer && i != q.correctIndex)
                            const Icon(Icons.cancel, color: Colors.red),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              if (_answered)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _nextQuestion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.childGreen,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      _currentIndex < widget.questions.length - 1
                          ? 'Next Question'
                          : 'See Results',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResults() {
    final total = widget.questions.length;
    final pct = (_score / total * 100).round();
    final emoji = pct >= 80 ? '🏆' : pct >= 60 ? '⭐' : '💪';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 80)),
            const SizedBox(height: 24),
            Text(
              'Game Over!',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'You scored $_score out of $total',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 8),
            Text(
              '$pct%',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: pct >= 80
                    ? Colors.green
                    : pct >= 60
                        ? Colors.orange
                        : Colors.red,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              pct >= 80
                  ? 'Amazing! You know your Bible really well! 🎉'
                  : pct >= 60
                      ? 'Great job! Keep reading your Bible! 📖'
                      : 'Keep practicing! You\'re learning! 💡',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55)),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _currentIndex = 0;
                      _score = 0;
                      _selectedAnswer = null;
                      _answered = false;
                      _gameOver = false;
                    });
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Play Again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.childGreen,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.home),
                  label: const Text('Back'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.gameTitle),
        backgroundColor: AppColors.childGreen,
        foregroundColor: Colors.white,
      ),
      body: _gameOver ? _buildResults() : _buildQuestion(),
    );
  }
}
