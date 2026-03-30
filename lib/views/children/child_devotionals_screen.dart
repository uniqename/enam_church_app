import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/colors.dart';

class ChildDevotionalsScreen extends StatefulWidget {
  const ChildDevotionalsScreen({super.key});

  @override
  State<ChildDevotionalsScreen> createState() => _ChildDevotionalsScreenState();
}

class _ChildDevotionalsScreenState extends State<ChildDevotionalsScreen> {
  static const _prefsKey = 'local_devotionals_v2';
  static const _completedKey = 'child_devotionals_completed';

  List<_ChildDev> _devs = [];
  Set<String> _completed = {};
  String _ageGroup = 'kids';
  bool _loading = true;
  int _selected = 0;

  static List<_ChildDev> get _seeds => [
    _ChildDev(
      id: 'cd-001',
      title: 'God Loves You SO Much!',
      scripture: 'John 3:16',
      verse: 'For God so loved the world that He gave His one and only Son.',
      body: 'Did you know God loves you more than anything? He loves you even more than your favorite toy, your pet, or even pizza! God loves you SO much that He sent His son Jesus just for you. You are super special to God!',
      reflection: 'Draw or write one thing that shows how much God loves you!',
      prayer: 'Thank You God for loving me so much. Help me to love others the way You love me. In Jesus name, Amen! 🙏',
      emoji: '💖',
      ageGroup: 'little',
    ),
    _ChildDev(
      id: 'cd-002',
      title: 'Jesus is My Best Friend',
      scripture: 'Proverbs 18:24',
      verse: 'There is a friend who sticks closer than a brother.',
      body: 'Jesus is the best friend you will ever have! He is always there when you are sad, scared, or happy. You can talk to Him anytime — in your room, at school, even on the playground! He always listens.',
      reflection: 'What would you tell your best friend Jesus today?',
      prayer: 'Jesus, thank You for being my best friend. Help me to talk to You every day. Amen! 😊',
      emoji: '🤝',
      ageGroup: 'little',
    ),
    _ChildDev(
      id: 'cd-003',
      title: 'Be Kind — It\'s What Jesus Does!',
      scripture: 'Ephesians 4:32',
      verse: 'Be kind to one another, tenderhearted, forgiving one another.',
      body: 'Sometimes people say mean things or leave us out. It hurts! But Jesus shows us what to do — be kind anyway. Jesus was kind even to people who were not nice to Him. When you choose to be kind, you are acting just like Jesus. How cool is that?',
      reflection: 'Think of one person you can be extra kind to today. What will you do?',
      prayer: 'Jesus, help me to be kind even when it\'s hard. I want to be like You. Amen! 🌟',
      emoji: '🌈',
      ageGroup: 'kids',
    ),
    _ChildDev(
      id: 'cd-004',
      title: 'Don\'t Be Afraid — God is With You!',
      scripture: 'Isaiah 41:10',
      verse: 'Do not fear, for I am with you. Do not be afraid, for I am your God.',
      body: 'Are you ever scared of the dark? Or of starting at a new school? Everyone gets scared sometimes — even grown-ups! But God says "Don\'t be afraid — I am RIGHT HERE with you." God never leaves you alone. Not even for one second.',
      reflection: 'What is something you are scared of? Tell God about it and let Him help you!',
      prayer: 'God, when I feel scared, remind me that You are always with me. I trust You! Amen 💪',
      emoji: '🦁',
      ageGroup: 'little',
    ),
    _ChildDev(
      id: 'cd-005',
      title: 'You Are Made in God\'s Image',
      scripture: 'Genesis 1:27',
      verse: 'So God created mankind in His own image.',
      body: 'God made you! Every part of you — your smile, your laugh, the way you think — is made by God. You are not an accident. You are not a mistake. You are a MASTERPIECE made by the greatest Creator in the universe. When you look in the mirror, remember: I am made in God\'s image!',
      reflection: 'Write or draw three amazing things about yourself that God made.',
      prayer: 'God, thank You for making me exactly the way I am. Help me to love who You made me to be! Amen 🙌',
      emoji: '✨',
      ageGroup: 'kids',
    ),
    _ChildDev(
      id: 'cd-006',
      title: 'The Power of Prayer',
      scripture: 'Philippians 4:6',
      verse: 'Do not be anxious about anything, but in everything, by prayer, present your requests to God.',
      body: 'Prayer is like having a superpower! When you pray, you are talking directly to God — the One who created the whole universe. He actually listens to YOU. You don\'t need special words. Just talk to God like you would talk to your best friend. Tell Him what you need, what you\'re thankful for, and what worries you.',
      reflection: 'Make a list of 3 things you want to pray about this week.',
      prayer: 'God, thank You that I can talk to You anytime. Help me to pray every day and trust You with everything. Amen! 🙏',
      emoji: '⚡',
      ageGroup: 'kids',
    ),
    _ChildDev(
      id: 'cd-007',
      title: 'Trust in God\'s Plan',
      scripture: 'Jeremiah 29:11',
      verse: '"For I know the plans I have for you," declares the Lord, "plans to give you hope and a future."',
      body: 'Have you ever tried to put together a puzzle without looking at the box? It feels confusing! Life can feel like that sometimes — like things don\'t make sense. But God can see the whole picture. He has an amazing plan for your life, even when things seem hard or confusing. You can trust Him.',
      reflection: 'Is there something in your life right now that feels confusing? How can you trust God with it?',
      prayer: 'God, I trust that You have a good plan for me. Help me to follow You even when I don\'t understand everything. Amen! 💫',
      emoji: '🗺️',
      ageGroup: 'teen',
    ),
    _ChildDev(
      id: 'cd-008',
      title: 'Your Words Have Power',
      scripture: 'Proverbs 18:21',
      verse: 'The tongue has the power of life and death.',
      body: 'The things you say really matter. Words can encourage someone and make their whole day better — or they can hurt someone deeply. God designed our words to carry power. That\'s why the Bible says to speak life! Before you say something about someone, ask yourself: Is it true? Is it kind? Is it necessary?',
      reflection: 'How can you use your words to encourage someone in your life this week?',
      prayer: 'God, help me to use my words to build people up and not tear them down. Put a guard over my mouth and fill my heart with kindness. Amen! 🌟',
      emoji: '🗣️',
      ageGroup: 'teen',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final prefs = await SharedPreferences.getInstance();

    // Load from main devotionals store
    List<_ChildDev> all = [];
    final raw = prefs.getString(_prefsKey);
    if (raw != null) {
      try {
        final list = jsonDecode(raw) as List;
        final mapped = list
            .map((j) => j as Map<String, dynamic>)
            .where((j) => (j['age_group'] as String? ?? 'all') != 'all')
            .map((j) => _ChildDev.fromJson(j))
            .toList();
        if (mapped.isNotEmpty) all.addAll(mapped);
      } catch (_) {}
    }
    // Always include our seeds (filtered by ageGroup)
    for (final seed in _seeds) {
      if (!all.any((d) => d.id == seed.id)) all.add(seed);
    }

    final completedRaw = prefs.getString(_completedKey);
    Set<String> completed = {};
    if (completedRaw != null) {
      try {
        completed = Set<String>.from(jsonDecode(completedRaw) as List);
      } catch (_) {}
    }

    setState(() {
      _devs = all;
      _completed = completed;
      _selected = 0;
      _loading = false;
    });
  }

  Future<void> _markComplete(String id) async {
    final prefs = await SharedPreferences.getInstance();
    _completed.add(id);
    await prefs.setString(_completedKey, jsonEncode(_completed.toList()));
    setState(() {});
  }

  List<_ChildDev> get _filtered =>
      _devs.where((d) => d.ageGroup == _ageGroup).toList();

  @override
  Widget build(BuildContext context) {
    final list = _filtered;
    final dev = list.isNotEmpty
        ? list[_selected.clamp(0, list.length - 1)]
        : null;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF13131A),
        title: Row(children: [
          const Text('✨ ', style: TextStyle(fontSize: 20)),
          Text('Kids Devotionals',
              style: TextStyle(
                  color: _ageColor(),
                  fontWeight: FontWeight.bold,
                  fontSize: 18)),
        ]),
        iconTheme: IconThemeData(color: _ageColor()),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _load,
            color: Colors.white38,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: Row(
              children: [
                {'id': 'little', 'label': '🌱 Little (5-8)', 'color': AppColors.childGreen},
                {'id': 'kids', 'label': '⭐ Kids (9-12)', 'color': AppColors.childBlue},
                {'id': 'teen', 'label': '🔥 Teen', 'color': AppColors.childPurple},
              ].map((tab) {
                final sel = _ageGroup == tab['id'];
                final c = tab['color'] as Color;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() {
                      _ageGroup = tab['id'] as String;
                      _selected = 0;
                    }),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: sel ? c.withValues(alpha: 0.2) : const Color(0xFF1C1C26),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: sel ? c : const Color(0xFF2A2A38)),
                      ),
                      child: Center(
                        child: Text(tab['label'] as String,
                            style: TextStyle(
                                color: sel ? c : Colors.white38,
                                fontSize: 11,
                                fontWeight: sel
                                    ? FontWeight.bold
                                    : FontWeight.normal)),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
      body: _loading
          ? Center(
              child: CircularProgressIndicator(color: _ageColor()))
          : Column(
              children: [
                // Devotional carousel dots
                if (list.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: list.asMap().entries.map((e) {
                        final sel = _selected == e.key;
                        final done = _completed.contains(e.value.id);
                        return GestureDetector(
                          onTap: () => setState(() => _selected = e.key),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: sel ? 24 : 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: done
                                  ? AppColors.success
                                  : sel
                                      ? _ageColor()
                                      : Colors.white24,
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                // Content
                Expanded(
                  child: dev != null
                      ? SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: _ChildDevCard(
                            dev: dev,
                            isCompleted: _completed.contains(dev.id),
                            ageColor: _ageColor(),
                            onComplete: () => _markComplete(dev.id),
                            onNext: _selected < list.length - 1
                                ? () => setState(() => _selected++)
                                : null,
                            onPrev: _selected > 0
                                ? () => setState(() => _selected--)
                                : null,
                          ),
                        )
                      : const Center(
                          child: Text('No devotionals for this age group yet!',
                              style: TextStyle(color: Colors.white38))),
                ),
              ],
            ),
    );
  }

  Color _ageColor() {
    switch (_ageGroup) {
      case 'little': return AppColors.childGreen;
      case 'teen':   return AppColors.childPurple;
      default:       return AppColors.childBlue;
    }
  }
}

// ── Child Devotional Card ──────────────────────────────────────────────────────
class _ChildDevCard extends StatefulWidget {
  final _ChildDev dev;
  final bool isCompleted;
  final Color ageColor;
  final VoidCallback onComplete;
  final VoidCallback? onNext;
  final VoidCallback? onPrev;

  const _ChildDevCard({
    required this.dev,
    required this.isCompleted,
    required this.ageColor,
    required this.onComplete,
    this.onNext,
    this.onPrev,
  });

  @override
  State<_ChildDevCard> createState() => _ChildDevCardState();
}

class _ChildDevCardState extends State<_ChildDevCard> {
  bool _showPrayer = false;

  @override
  Widget build(BuildContext context) {
    final dev = widget.dev;
    final c = widget.ageColor;

    return Column(
      children: [
        // Hero emoji + title
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [c.withValues(alpha: 0.3), const Color(0xFF0D0D1A)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: c.withValues(alpha: 0.4)),
          ),
          child: Column(
            children: [
              Text(dev.emoji, style: const TextStyle(fontSize: 52)),
              const SizedBox(height: 10),
              Text(dev.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 22)),
              const SizedBox(height: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                decoration: BoxDecoration(
                  color: c.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(dev.scripture,
                    style: TextStyle(color: c, fontSize: 13)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Bible verse
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: c.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: c.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Text('📖', style: TextStyle(fontSize: 24)),
              const SizedBox(height: 8),
              Text('"${dev.verse}"',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      height: 1.5)),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Body text — simplified, fun
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF13131A),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF2A2A38)),
          ),
          child: Text(dev.body,
              style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                  height: 1.8)),
        ),
        const SizedBox(height: 14),

        // Reflection — big, fun, colorful
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.accentGold.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: AppColors.accentGold.withValues(alpha: 0.4)),
          ),
          child: Column(
            children: [
              const Text('💭 Think About This!',
                  style: TextStyle(
                      color: AppColors.accentGold,
                      fontWeight: FontWeight.bold,
                      fontSize: 15)),
              const SizedBox(height: 10),
              Text(dev.reflection,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      height: 1.5)),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Prayer (tap to reveal)
        GestureDetector(
          onTap: () => setState(() => _showPrayer = !_showPrayer),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.childGreen.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: AppColors.childGreen.withValues(alpha: 0.4)),
            ),
            child: Column(
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Text('🙏 ', style: TextStyle(fontSize: 18)),
                  const Text('Pray With Me',
                      style: TextStyle(
                          color: AppColors.childGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 15)),
                  const Spacer(),
                  Icon(
                    _showPrayer
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: AppColors.childGreen,
                  ),
                ]),
                if (_showPrayer) ...[
                  const SizedBox(height: 12),
                  Text(dev.prayer,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          height: 1.7)),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Complete button
        if (!widget.isCompleted)
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: c,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            icon: const Icon(Icons.star, size: 20),
            label: const Text('I Read This! ⭐',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            onPressed: widget.onComplete,
          )
        else
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: AppColors.success.withValues(alpha: 0.4)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, color: AppColors.success),
                SizedBox(width: 8),
                Text('Great job! You completed this! 🎉',
                    style: TextStyle(
                        color: AppColors.success,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        const SizedBox(height: 16),

        // Navigation
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (widget.onPrev != null)
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white54,
                  side: const BorderSide(color: Color(0xFF2A2A38)),
                ),
                icon: const Icon(Icons.arrow_back, size: 16),
                label: const Text('Previous'),
                onPressed: widget.onPrev,
              )
            else
              const SizedBox(),
            if (widget.onNext != null)
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    backgroundColor: c.withValues(alpha: 0.6)),
                icon: const Icon(Icons.arrow_forward, size: 16),
                label: const Text('Next'),
                onPressed: widget.onNext,
              )
            else
              const SizedBox(),
          ],
        ),
        const SizedBox(height: 30),
      ],
    );
  }
}

// ── Model ──────────────────────────────────────────────────────────────────────
class _ChildDev {
  final String id;
  final String title;
  final String scripture;
  final String verse;
  final String body;
  final String reflection;
  final String prayer;
  final String emoji;
  final String ageGroup;

  const _ChildDev({
    required this.id,
    required this.title,
    required this.scripture,
    required this.verse,
    required this.body,
    required this.reflection,
    required this.prayer,
    required this.emoji,
    required this.ageGroup,
  });

  factory _ChildDev.fromJson(Map<String, dynamic> j) => _ChildDev(
    id: j['id'] as String? ?? DateTime.now().toString(),
    title: j['title'] as String? ?? '',
    scripture: j['scripture'] as String? ?? '',
    verse: j['verse'] as String? ?? '',
    body: j['body'] as String? ?? '',
    reflection: j['reflection'] as String? ?? '',
    prayer: j['prayer'] as String? ?? '',
    emoji: j['emoji'] as String? ?? '✨',
    ageGroup: j['age_group'] as String? ?? 'kids',
  );
}
