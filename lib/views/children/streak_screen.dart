import 'package:flutter/material.dart';
import '../../services/streak_service.dart';
import '../../utils/colors.dart';

class StreakScreen extends StatefulWidget {
  const StreakScreen({super.key});

  @override
  State<StreakScreen> createState() => _StreakScreenState();
}

class _StreakScreenState extends State<StreakScreen> {
  final _streakService = StreakService();
  int _current = 0;
  int _longest = 0;
  int _total = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final current = await _streakService.getCurrentStreak();
    final longest = await _streakService.getLongestStreak();
    final total = await _streakService.getTotalDays();
    setState(() {
      _current = current;
      _longest = longest;
      _total = total;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final emoji = _streakService.streakEmoji(_current);
    final message = _streakService.streakMessage(_current);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Streak'),
        backgroundColor: AppColors.childOrange,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Main streak display
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.childOrange,
                    AppColors.childOrange.withValues(alpha: 0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.childOrange.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 64)),
                  const SizedBox(height: 12),
                  Text(
                    '$_current',
                    style: const TextStyle(
                      fontSize: 80,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1,
                    ),
                  ),
                  const Text(
                    'Day Streak',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    message,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Stats row
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    emoji: '🏆',
                    label: 'Best Streak',
                    value: '$_longest days',
                    color: AppColors.childYellow,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _StatCard(
                    emoji: '📅',
                    label: 'Total Days',
                    value: '$_total days',
                    color: AppColors.childBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Milestones
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Streak Milestones',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            ..._milestones().map((m) => _MilestoneTile(
                  emoji: m['emoji'] as String,
                  days: m['days'] as int,
                  label: m['label'] as String,
                  current: _current,
                )),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.childGreen.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppColors.childGreen.withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Text('💡', style: TextStyle(fontSize: 24)),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Open the app every day to grow your streak! The more you come, the more you learn about God.',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _milestones() => [
        {'emoji': '🌱', 'days': 1, 'label': 'First Day'},
        {'emoji': '🌿', 'days': 3, 'label': '3-Day Streak'},
        {'emoji': '🔥', 'days': 7, 'label': '1-Week Warrior'},
        {'emoji': '⭐', 'days': 14, 'label': '2-Week Champion'},
        {'emoji': '🌟', 'days': 21, 'label': '3-Week Legend'},
        {'emoji': '👑', 'days': 30, 'label': '30-Day Bible Hero'},
      ];
}

class _StatCard extends StatelessWidget {
  final String emoji;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.emoji,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: color),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class _MilestoneTile extends StatelessWidget {
  final String emoji;
  final int days;
  final String label;
  final int current;

  const _MilestoneTile({
    required this.emoji,
    required this.days,
    required this.label,
    required this.current,
  });

  @override
  Widget build(BuildContext context) {
    final achieved = current >= days;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: achieved
              ? AppColors.childOrange.withValues(alpha: 0.1)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: achieved
                ? AppColors.childOrange.withValues(alpha: 0.4)
                : Colors.grey.shade200,
          ),
        ),
        child: Row(
          children: [
            Text(
              achieved ? emoji : '🔒',
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: achieved ? Colors.black87 : Colors.grey,
                    ),
                  ),
                  Text(
                    '$days days',
                    style: TextStyle(
                        fontSize: 12,
                        color: achieved
                            ? AppColors.childOrange
                            : Colors.grey),
                  ),
                ],
              ),
            ),
            if (achieved)
              const Icon(Icons.check_circle,
                  color: AppColors.childOrange, size: 20),
          ],
        ),
      ),
    );
  }
}
