import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../utils/colors.dart';

class DevotionalsScreen extends StatefulWidget {
  const DevotionalsScreen({super.key});

  @override
  State<DevotionalsScreen> createState() => _DevotionalsScreenState();
}

class _DevotionalsScreenState extends State<DevotionalsScreen> {
  int _selectedIndex = 0;

  // Static devotionals — replace with Supabase fetch as the content library grows
  static final List<_Devotional> _devotionals = [
    _Devotional(
      title: 'Walk in Faith',
      date: DateTime.now(),
      scripture: 'Hebrews 11:1',
      verse:
          'Now faith is the substance of things hoped for, the evidence of things not seen.',
      body:
          'Faith is not passive waiting — it is active trust. Every step you take toward God\'s promise, even when the path is unclear, is an act of faith. Abraham left his homeland without knowing where he was going. The disciples left their nets without knowing what they were walking into.\n\nToday, what is God asking you to trust Him with? Your finances? A relationship? A dream? Take one bold step today. God honors faith that moves.',
      reflection: 'What area of your life is God calling you to trust Him more fully?',
      prayer:
          'Lord, increase my faith. Help me to trust You even when I cannot see the full picture. I choose to walk by faith, not by sight. Amen.',
    ),
    _Devotional(
      title: 'The Power of Gratitude',
      date: DateTime.now().subtract(const Duration(days: 1)),
      scripture: '1 Thessalonians 5:18',
      verse:
          'In everything give thanks; for this is the will of God in Christ Jesus for you.',
      body:
          'Gratitude is not about circumstances — it is about perspective. Paul wrote "give thanks in everything" from a prison cell. He didn\'t say give thanks for everything, but in everything.\n\nGratitude shifts your focus from what you lack to what you have. It opens your eyes to God\'s faithfulness in the small things — a breath in the morning, a friend\'s encouragement, a meal on your table.',
      reflection: 'Name three specific things you are grateful for that you often overlook.',
      prayer:
          'Father, forgive me for when I complain instead of being grateful. Open my eyes to Your daily mercies. Thank You for every blessing, seen and unseen. Amen.',
    ),
    _Devotional(
      title: 'Renewing the Mind',
      date: DateTime.now().subtract(const Duration(days: 2)),
      scripture: 'Romans 12:2',
      verse:
          'Do not be conformed to this world, but be transformed by the renewing of your mind.',
      body:
          'The battlefield of the Christian life is the mind. What you think shapes what you feel, what you say, and what you do. Every day, the world bombards us with messages that contradict God\'s truth.\n\nRenewing your mind means deliberately replacing lies with truth. It happens through time in the Word, worship, prayer, and godly community. It\'s not a one-time event — it\'s a daily discipline that produces lasting transformation.',
      reflection: 'What thoughts or mindsets do you need to surrender to God today?',
      prayer:
          'Holy Spirit, guard my mind. Expose every lie I have believed and replace it with Your truth. Transform me from the inside out, starting with my thoughts. Amen.',
    ),
    _Devotional(
      title: 'Serving with Joy',
      date: DateTime.now().subtract(const Duration(days: 3)),
      scripture: 'Mark 10:45',
      verse:
          'For even the Son of Man came not to be served but to serve, and to give his life as a ransom for many.',
      body:
          'Jesus redefined greatness. In a world that celebrates power and status, He knelt down and washed dirty feet. His model of leadership was servanthood — not as a weakness, but as strength under submission.\n\nWhen we serve others joyfully, we reflect the character of Christ. Every act of service, no matter how small, is worship when done with the right heart.',
      reflection: 'How can you serve someone in your community this week?',
      prayer:
          'Jesus, give me a servant\'s heart. Help me find joy in serving others just as You served. May my service point people to You. Amen.',
    ),
    _Devotional(
      title: 'God\'s Perfect Peace',
      date: DateTime.now().subtract(const Duration(days: 4)),
      scripture: 'Philippians 4:7',
      verse:
          'And the peace of God, which surpasses all understanding, will guard your hearts and minds through Christ Jesus.',
      body:
          'God\'s peace is not the absence of problems — it is a settled confidence that He is in control. It surpasses human understanding because it doesn\'t make logical sense. How can someone be at peace in the middle of a storm? Only God can give that.\n\nWhen anxiety rises, the antidote is prayer with thanksgiving. Cast your cares on Him, trust His sovereignty, and allow His peace to be the guard over your heart.',
      reflection: 'What worry are you carrying that you need to give to God right now?',
      prayer:
          'Lord, I give You my fears and anxieties. I choose Your peace over my worries. Guard my heart and mind in Christ Jesus. Amen.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final devotional = _devotionals[_selectedIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Devotionals'),
        backgroundColor: AppColors.purple,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildDateRow(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _buildDevotionalCard(devotional),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRow() {
    return Container(
      color: AppColors.purple.withValues(alpha: 0.06),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _devotionals.asMap().entries.map((entry) {
            final i = entry.key;
            final d = entry.value;
            final isSelected = i == _selectedIndex;
            final label = i == 0
                ? 'Today'
                : i == 1
                    ? 'Yesterday'
                    : DateFormat('EEE d').format(d.date);

            return GestureDetector(
              onTap: () => setState(() => _selectedIndex = i),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.purple : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.purple
                        : AppColors.purple.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.purple,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildDevotionalCard(_Devotional d) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('EEEE, MMMM d').format(d.date),
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 6),
              Text(
                d.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      d.scripture,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '"${d.verse}"',
                      style: const TextStyle(
                        color: Colors.white,
                        fontStyle: FontStyle.italic,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Body
        _section('Devotional', Icons.auto_stories, d.body),
        const SizedBox(height: 16),
        // Reflection
        _card(
          icon: Icons.lightbulb_outline,
          color: AppColors.warning,
          title: 'Reflection',
          body: d.reflection,
        ),
        const SizedBox(height: 12),
        // Prayer
        _card(
          icon: Icons.favorite_border,
          color: AppColors.error,
          title: 'Prayer',
          body: d.prayer,
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _section(String title, IconData icon, String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: AppColors.purple),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          text,
          style: const TextStyle(fontSize: 15, height: 1.65),
        ),
      ],
    );
  }

  Widget _card({
    required IconData icon,
    required Color color,
    required String title,
    required String body,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(body, style: const TextStyle(fontSize: 14, height: 1.55)),
        ],
      ),
    );
  }
}

class _Devotional {
  final String title;
  final DateTime date;
  final String scripture;
  final String verse;
  final String body;
  final String reflection;
  final String prayer;

  const _Devotional({
    required this.title,
    required this.date,
    required this.scripture,
    required this.verse,
    required this.body,
    required this.reflection,
    required this.prayer,
  });
}
