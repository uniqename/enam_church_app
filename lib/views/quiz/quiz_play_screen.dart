import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/quiz_model.dart';
import '../../services/quiz_service.dart';
import '../../utils/colors.dart';

class QuizPlayScreen extends StatefulWidget {
  final QuizModel quiz;
  final String userId;
  final String userName;

  const QuizPlayScreen({
    super.key,
    required this.quiz,
    required this.userId,
    required this.userName,
  });

  @override
  State<QuizPlayScreen> createState() => _QuizPlayScreenState();
}

class _QuizPlayScreenState extends State<QuizPlayScreen>
    with TickerProviderStateMixin {
  // ── State ───────────────────────────────────────────────────────────────
  int _currentIndex = 0;
  int _totalScore = 0;
  int _timeLeft = 0;
  bool _answered = false;
  int? _selectedAnswer;
  bool _gameOver = false;
  bool _showCountdown = true;
  int _countdownValue = 3;
  int _pointsEarned = 0;
  bool _showPointsBurst = false;

  Timer? _timer;
  late AnimationController _timerAnimController;
  late Animation<double> _timerAnim;
  late AnimationController _scaleAnimController;
  late Animation<double> _scaleAnim;

  // Kahoot-style answer tile colors
  static const _tileColors = [
    Color(0xFFE53935), // red   – A
    Color(0xFF1E88E5), // blue  – B
    Color(0xFFFDD835), // yellow– C
    Color(0xFF43A047), // green – D
  ];
  static const _tileIcons = [
    Icons.change_history, // triangle – A
    Icons.diamond_outlined, // diamond  – B
    Icons.circle_outlined, // circle   – C
    Icons.square_outlined, // square   – D
  ];

  QuizQuestion get _currentQuestion =>
      widget.quiz.questions[_currentIndex];

  @override
  void initState() {
    super.initState();
    _timerAnimController = AnimationController(vsync: this);
    _timerAnim = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _timerAnimController, curve: Curves.linear),
    );
    _scaleAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnim = CurvedAnimation(
        parent: _scaleAnimController, curve: Curves.elasticOut);
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timerAnimController.dispose();
    _scaleAnimController.dispose();
    super.dispose();
  }

  // ── Countdown before quiz starts ────────────────────────────────────────
  void _startCountdown() {
    setState(() {
      _showCountdown = true;
      _countdownValue = 3;
    });
    Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() => _countdownValue--);
      if (_countdownValue <= 0) {
        t.cancel();
        setState(() => _showCountdown = false);
        _startQuestion();
      }
    });
  }

  // ── Per-question timer ───────────────────────────────────────────────────
  void _startQuestion() {
    final limit = _currentQuestion.timeLimitSeconds;
    setState(() {
      _timeLeft = limit;
      _answered = false;
      _selectedAnswer = null;
      _pointsEarned = 0;
      _showPointsBurst = false;
    });
    _timerAnimController.duration = Duration(seconds: limit);
    _timerAnimController.forward(from: 0.0);

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() => _timeLeft--);
      if (_timeLeft <= 0) {
        t.cancel();
        _onTimeUp();
      }
    });
  }

  void _onTimeUp() {
    if (_answered) return;
    setState(() => _answered = true);
    Future.delayed(const Duration(milliseconds: 1800), _nextQuestion);
  }

  void _onAnswerTapped(int choiceIndex) {
    if (_answered) return;
    _timer?.cancel();
    _timerAnimController.stop();

    final isCorrect = choiceIndex == _currentQuestion.correctIndex;
    // Points: base 1000, bonus based on remaining time ratio
    int pts = 0;
    if (isCorrect) {
      final ratio = _timeLeft / _currentQuestion.timeLimitSeconds;
      pts = (500 + (500 * ratio)).round();
      _totalScore += pts;
    }

    setState(() {
      _answered = true;
      _selectedAnswer = choiceIndex;
      _pointsEarned = pts;
      _showPointsBurst = isCorrect;
    });

    if (isCorrect) {
      _scaleAnimController.forward(from: 0.0);
    }
    Future.delayed(const Duration(milliseconds: 2000), _nextQuestion);
  }

  void _nextQuestion() {
    if (!mounted) return;
    if (_currentIndex + 1 >= widget.quiz.questions.length) {
      _endGame();
    } else {
      setState(() => _currentIndex++);
      _startQuestion();
    }
  }

  void _endGame() {
    _timer?.cancel();
    setState(() => _gameOver = true);
    // Save score
    QuizService().saveScore(
      quizId: widget.quiz.id,
      userId: widget.userId,
      userName: widget.userName,
      score: _totalScore,
      totalQuestions: widget.quiz.questions.length,
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (_showCountdown) return _buildCountdownScreen();
    if (_gameOver) return _buildEndScreen();
    return _buildQuizScreen();
  }

  // ── Countdown screen ─────────────────────────────────────────────────────
  Widget _buildCountdownScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFF1A0030),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.quiz.title,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '${widget.quiz.questions.length} questions',
              style: const TextStyle(color: Colors.white60, fontSize: 14),
            ),
            const SizedBox(height: 60),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                _countdownValue > 0 ? '$_countdownValue' : 'GO!',
                key: ValueKey(_countdownValue),
                style: TextStyle(
                  fontSize: 80,
                  fontWeight: FontWeight.bold,
                  color: _countdownValue > 0
                      ? const Color(0xFFFFC107)
                      : AppColors.success,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Get ready!',
                style: TextStyle(color: Colors.white70, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  // ── Active quiz screen ───────────────────────────────────────────────────
  Widget _buildQuizScreen() {
    final question = _currentQuestion;
    final total = widget.quiz.questions.length;

    return Scaffold(
      backgroundColor: const Color(0xFF1A0030),
      body: SafeArea(
        child: Column(
          children: [
            // ── Header bar ─────────────────────────────────────────────
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  // Back button
                  GestureDetector(
                    onTap: () => _confirmQuit(),
                    child: const Icon(Icons.close, color: Colors.white60),
                  ),
                  const SizedBox(width: 12),
                  // Progress pills
                  Expanded(
                    child: Row(
                      children: List.generate(total, (i) {
                        Color c;
                        if (i < _currentIndex) {
                          c = AppColors.success;
                        } else if (i == _currentIndex) {
                          c = const Color(0xFFFFC107);
                        } else {
                          c = Colors.white24;
                        }
                        return Expanded(
                          child: Container(
                            height: 6,
                            margin: const EdgeInsets.only(right: 3),
                            decoration: BoxDecoration(
                              color: c,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Score
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFC107).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star,
                            color: Color(0xFFFFC107), size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '$_totalScore',
                          style: const TextStyle(
                              color: Color(0xFFFFC107),
                              fontWeight: FontWeight.bold,
                              fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // ── Question number + timer ─────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Question ${_currentIndex + 1} of $total',
                    style: const TextStyle(
                        color: Colors.white60, fontSize: 13),
                  ),
                  _buildTimerWidget(),
                ],
              ),
            ),
            // ── Question card ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(minHeight: 80),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    if (question.imageUrl != null &&
                        question.imageUrl!.isNotEmpty) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          question.imageUrl!,
                          height: 140,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            height: 60,
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.broken_image,
                                color: Colors.grey),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    Text(
                      question.question,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // ── Points burst ────────────────────────────────────────────
            if (_showPointsBurst)
              ScaleTransition(
                scale: _scaleAnim,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '+$_pointsEarned pts',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                ),
              ),
            // ── Answer grid ─────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 2.0,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: List.generate(
                    question.options.length,
                    (i) => _buildAnswerTile(i, question.options[i]),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimerWidget() {
    Color timerColor;
    if (_timeLeft > 10) {
      timerColor = AppColors.success;
    } else if (_timeLeft > 5) {
      timerColor = const Color(0xFFFFC107);
    } else {
      timerColor = AppColors.error;
    }

    return SizedBox(
      width: 48,
      height: 48,
      child: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedBuilder(
            animation: _timerAnim,
            builder: (_, __) => CircularProgressIndicator(
              value: _timerAnim.value,
              strokeWidth: 4,
              backgroundColor: Colors.white24,
              valueColor: AlwaysStoppedAnimation<Color>(timerColor),
            ),
          ),
          Center(
            child: Text(
              '$_timeLeft',
              style: TextStyle(
                color: timerColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerTile(int index, String text) {
    final color = _tileColors[index % _tileColors.length];
    final icon = _tileIcons[index % _tileIcons.length];

    Color tileColor;
    double opacity = 1.0;
    Widget? overlay;

    if (!_answered) {
      tileColor = color;
    } else if (index == _currentQuestion.correctIndex) {
      tileColor = AppColors.success;
      overlay = const Icon(Icons.check_circle, color: Colors.white, size: 22);
    } else if (index == _selectedAnswer) {
      tileColor = AppColors.error;
      opacity = 0.9;
      overlay = const Icon(Icons.cancel, color: Colors.white, size: 22);
    } else {
      tileColor = color;
      opacity = 0.25;
    }

    return AnimatedOpacity(
      opacity: opacity,
      duration: const Duration(milliseconds: 300),
      child: GestureDetector(
        onTap: _answered ? null : () => _onAnswerTapped(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: tileColor,
            borderRadius: BorderRadius.circular(14),
            boxShadow: _answered
                ? null
                : [
                    BoxShadow(
                      color: tileColor.withValues(alpha: 0.5),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ],
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(icon, color: Colors.white70, size: 16),
                    const Spacer(),
                    Text(
                      text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (overlay != null)
                Positioned(
                    top: 6,
                    right: 6,
                    child: overlay),
            ],
          ),
        ),
      ),
    );
  }

  // ── End screen ───────────────────────────────────────────────────────────
  Widget _buildEndScreen() {
    final total = widget.quiz.questions.length;
    final maxScore = total * 1000;
    final percent = maxScore > 0 ? (_totalScore / maxScore * 100).round() : 0;

    String emoji;
    String message;
    Color accentColor;

    if (percent >= 80) {
      emoji = '🏆';
      message = 'Outstanding! You\'re a champion!';
      accentColor = const Color(0xFFFFC107);
    } else if (percent >= 60) {
      emoji = '🌟';
      message = 'Great job! Keep it up!';
      accentColor = AppColors.success;
    } else if (percent >= 40) {
      emoji = '👏';
      message = 'Good effort! Practice makes perfect!';
      accentColor = const Color(0xFF1E88E5);
    } else {
      emoji = '💪';
      message = 'Keep learning and try again!';
      accentColor = const Color(0xFFE53935);
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1A0030),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              Text(emoji, style: const TextStyle(fontSize: 72)),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: accentColor,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.quiz.title,
                style:
                    const TextStyle(color: Colors.white60, fontSize: 14),
              ),
              const SizedBox(height: 32),
              // Score card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: accentColor.withValues(alpha: 0.4)),
                ),
                child: Column(
                  children: [
                    Text(
                      '$_totalScore',
                      style: TextStyle(
                        fontSize: 56,
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                      ),
                    ),
                    Text(
                      'points',
                      style: TextStyle(
                          fontSize: 14, color: accentColor.withValues(alpha: 0.7)),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _statChip('Questions', '$total', Colors.white60),
                        _statChip('Max possible', '$maxScore pts', Colors.white60),
                        _statChip('Score', '$percent%', accentColor),
                      ],
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Buttons
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _currentIndex = 0;
                      _totalScore = 0;
                      _answered = false;
                      _selectedAnswer = null;
                      _gameOver = false;
                      _showPointsBurst = false;
                    });
                    _startCountdown();
                  },
                  icon: const Icon(Icons.replay),
                  label: const Text('Play Again',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white70,
                    side: const BorderSide(color: Colors.white24),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Back to Quizzes',
                      style: TextStyle(fontSize: 15)),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statChip(String label, String value, Color color) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 14)),
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 11)),
      ],
    );
  }

  void _confirmQuit() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Quit Quiz?'),
        content:
            const Text('Your progress will be lost if you quit now.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Continue Playing'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child:
                const Text('Quit', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
