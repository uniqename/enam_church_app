import 'package:flutter/material.dart';
import '../../models/guided_prayer.dart';
import '../../utils/colors.dart';

class GuidedPrayerScreen extends StatelessWidget {
  const GuidedPrayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prayers = GuidedPrayer.defaults;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Guided Prayers'),
        backgroundColor: AppColors.childPink,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.childPink, AppColors.childPurple],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                children: [
                  Text('🙏', style: TextStyle(fontSize: 52)),
                  SizedBox(height: 8),
                  Text(
                    'Talk to God Today!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Choose a prayer and follow along',
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ...prayers.map((prayer) => _PrayerCard(prayer: prayer)),
          ],
        ),
      ),
    );
  }
}

class _PrayerCard extends StatelessWidget {
  final GuidedPrayer prayer;
  const _PrayerCard({required this.prayer});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => _GuidedPrayerWalkthrough(prayer: prayer),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.childPink.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(prayer.emoji,
                      style: const TextStyle(fontSize: 32)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      prayer.title,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.childPurple.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        prayer.category,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.childPurple),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${prayer.steps.length} steps',
                      style: const TextStyle(
                          fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.childPink),
            ],
          ),
        ),
      ),
    );
  }
}

class _GuidedPrayerWalkthrough extends StatefulWidget {
  final GuidedPrayer prayer;
  const _GuidedPrayerWalkthrough({required this.prayer});

  @override
  State<_GuidedPrayerWalkthrough> createState() =>
      _GuidedPrayerWalkthroughState();
}

class _GuidedPrayerWalkthroughState extends State<_GuidedPrayerWalkthrough> {
  int _step = 0;

  void _next() {
    if (_step < widget.prayer.steps.length - 1) {
      setState(() => _step++);
    } else {
      _finish();
    }
  }

  void _back() {
    if (_step > 0) setState(() => _step--);
  }

  void _finish() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Great job! 🎉'),
        content: const Text(
            'You finished your prayer! God heard every word. Keep talking to Him every day!'),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.childPink,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final step = widget.prayer.steps[_step];
    final total = widget.prayer.steps.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.prayer.title),
        backgroundColor: AppColors.childPink,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Progress
            Row(
              children: List.generate(
                total,
                (i) => Expanded(
                  child: Container(
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: i <= _step
                          ? AppColors.childPink
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Step ${_step + 1} of $total',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            // Emoji + instruction
            Center(
              child: Text(widget.prayer.emoji,
                  style: const TextStyle(fontSize: 64)),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.childPurple.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppColors.childPurple.withValues(alpha: 0.3)),
              ),
              child: Text(
                step.instruction,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.childPurple),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            // Prayer prompt
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.childPink.withValues(alpha: 0.1),
                      AppColors.childPurple.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    '"${step.prompt}"',
                    style: const TextStyle(
                      fontSize: 18,
                      fontStyle: FontStyle.italic,
                      color: Colors.black87,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Nav buttons
            Row(
              children: [
                if (_step > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _back,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.childPink),
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Back',
                          style: TextStyle(color: AppColors.childPink)),
                    ),
                  ),
                if (_step > 0) const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _next,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.childPink,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      _step == total - 1 ? 'Finish Prayer 🙏' : 'Next Step',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
