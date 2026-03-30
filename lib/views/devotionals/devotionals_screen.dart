import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/auth_service.dart';
import '../../utils/colors.dart';

class DevotionalsScreen extends StatefulWidget {
  const DevotionalsScreen({super.key});

  @override
  State<DevotionalsScreen> createState() => _DevotionalsScreenState();
}

class _DevotionalsScreenState extends State<DevotionalsScreen> {
  final _auth = AuthService();
  static const _prefsKey = 'local_devotionals_v2';

  List<_Devotional> _devotionals = [];
  int _selectedIndex = 0;
  bool _loading = true;
  bool _canEdit = false;
  String _ageFilter = 'all';

  static List<_Devotional> get _seeds => [
    _Devotional(
      id: 'dev-001',
      title: 'Walk in Faith',
      date: DateTime.now(),
      scripture: 'Hebrews 11:1',
      verse: 'Now faith is the substance of things hoped for, the evidence of things not seen.',
      body: 'Faith is not passive waiting — it is active trust. Every step you take toward God\'s promise, even when the path is unclear, is an act of faith. Abraham left his homeland without knowing where he was going. The disciples left their nets without knowing what they were walking into.\n\nToday, what is God asking you to trust Him with? Your finances? A relationship? A dream? Take one bold step today. God honors faith that moves.',
      reflection: 'What area of your life is God calling you to trust Him more fully?',
      prayer: 'Lord, increase my faith. Help me to trust You even when I cannot see the full picture. I choose to walk by faith, not by sight. Amen.',
      ageGroup: 'all',
    ),
    _Devotional(
      id: 'dev-002',
      title: 'The Power of Gratitude',
      date: DateTime.now().subtract(const Duration(days: 1)),
      scripture: '1 Thessalonians 5:18',
      verse: 'In everything give thanks; for this is the will of God in Christ Jesus for you.',
      body: 'Gratitude is not about circumstances — it is about perspective. Paul wrote "give thanks in everything" from a prison cell. He didn\'t say give thanks for everything, but in everything.\n\nGratitude shifts your focus from what you lack to what you have. It opens your eyes to God\'s faithfulness in the small things — a breath in the morning, a friend\'s encouragement, a meal on your table.',
      reflection: 'Name three specific things you are grateful for that you often overlook.',
      prayer: 'Father, forgive me for when I complain instead of being grateful. Open my eyes to Your daily mercies. Thank You for every blessing, seen and unseen. Amen.',
      ageGroup: 'all',
    ),
    _Devotional(
      id: 'dev-003',
      title: 'Renewing the Mind',
      date: DateTime.now().subtract(const Duration(days: 2)),
      scripture: 'Romans 12:2',
      verse: 'Do not be conformed to this world, but be transformed by the renewing of your mind.',
      body: 'The battlefield of the Christian life is the mind. What you think shapes what you feel, what you say, and what you do. Every day, the world bombards us with messages that contradict God\'s truth.\n\nRenewing your mind means deliberately replacing lies with truth. It happens through time in the Word, worship, prayer, and godly community.',
      reflection: 'What thoughts or mindsets do you need to surrender to God today?',
      prayer: 'Holy Spirit, guard my mind. Expose every lie I have believed and replace it with Your truth. Transform me from the inside out. Amen.',
      ageGroup: 'teen',
    ),
    _Devotional(
      id: 'dev-004',
      title: 'Serving with Joy',
      date: DateTime.now().subtract(const Duration(days: 3)),
      scripture: 'Mark 10:45',
      verse: 'For even the Son of Man came not to be served but to serve.',
      body: 'Jesus redefined greatness. In a world that celebrates power and status, He knelt down and washed dirty feet. His model of leadership was servanthood — not as a weakness, but as strength under submission.\n\nWhen we serve others joyfully, we reflect the character of Christ. Every act of service, no matter how small, is worship when done with the right heart.',
      reflection: 'How can you serve someone in your community this week?',
      prayer: 'Jesus, give me a servant\'s heart. Help me find joy in serving others just as You served. Amen.',
      ageGroup: 'all',
    ),
    _Devotional(
      id: 'dev-005',
      title: 'God\'s Perfect Peace',
      date: DateTime.now().subtract(const Duration(days: 4)),
      scripture: 'Philippians 4:7',
      verse: 'And the peace of God, which surpasses all understanding, will guard your hearts and minds.',
      body: 'God\'s peace is not the absence of problems — it is a settled confidence that He is in control. It surpasses human understanding because it doesn\'t make logical sense.\n\nWhen anxiety rises, the antidote is prayer with thanksgiving. Cast your cares on Him, trust His sovereignty, and allow His peace to be the guard over your heart.',
      reflection: 'What worry are you carrying that you need to give to God right now?',
      prayer: 'Lord, I give You my fears and anxieties. I choose Your peace over my worries. Guard my heart and mind in Christ Jesus. Amen.',
      ageGroup: 'all',
    ),
    _Devotional(
      id: 'dev-children-001',
      title: 'Jesus Loves You!',
      date: DateTime.now().subtract(const Duration(days: 5)),
      scripture: 'John 3:16',
      verse: 'For God so loved the world that He gave His one and only Son.',
      body: 'God loves you so much! He sent His son Jesus because He wanted you to be His friend forever. You are so special to God — He knows your name and counts every hair on your head!',
      reflection: 'How does it feel to know that God loves you so much?',
      prayer: 'Thank You God for loving me. Help me to love others the way You love me. Amen.',
      ageGroup: 'little',
    ),
    _Devotional(
      id: 'dev-children-002',
      title: 'Be Kind Like Jesus',
      date: DateTime.now().subtract(const Duration(days: 6)),
      scripture: 'Ephesians 4:32',
      verse: 'Be kind to one another, tenderhearted, forgiving one another.',
      body: 'Jesus was always kind. He helped sick people, fed hungry people, and played with children! When someone is mean to us, we can still choose to be kind — because that\'s what Jesus would do.',
      reflection: 'Think of one person you can be extra kind to today. What will you do?',
      prayer: 'Jesus, help me to be kind even when it\'s hard. I want to be like You. Amen.',
      ageGroup: 'children',
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
    final raw = prefs.getString(_prefsKey);
    List<_Devotional> list;
    if (raw != null) {
      try {
        list = (jsonDecode(raw) as List)
            .map((j) => _Devotional.fromJson(j as Map<String, dynamic>))
            .toList();
      } catch (_) {
        list = _seeds;
      }
    } else {
      list = _seeds;
      await _save(list);
    }
    final role = await _auth.getUserRole();
    setState(() {
      _devotionals = list;
      _canEdit = role == 'admin' || role == 'pastor';
      _selectedIndex = 0;
      _loading = false;
    });
  }

  Future<void> _save(List<_Devotional> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode(list.map((d) => d.toJson()).toList()));
  }

  List<_Devotional> get _filtered {
    if (_ageFilter == 'all') return _devotionals;
    return _devotionals.where((d) => d.ageGroup == _ageFilter || d.ageGroup == 'all').toList();
  }

  @override
  Widget build(BuildContext context) {
    final list = _filtered;
    final dev = list.isNotEmpty ? list[_selectedIndex.clamp(0, list.length - 1)] : null;

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        backgroundColor: AppColors.darkSurface,
        title: const Text('Daily Devotionals',
            style: TextStyle(
                color: AppColors.accentPurple, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: AppColors.accentPurple),
        actions: [
          if (_canEdit)
            IconButton(
              icon: const Icon(Icons.add, color: AppColors.accentPurple),
              onPressed: () => _showForm(null),
            ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white54),
            onPressed: _load,
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.accentPurple))
          : Column(
              children: [
                // Age group filter
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        {'id': 'all', 'label': '🙏 All'},
                        {'id': 'little', 'label': '🌱 Little (5-8)'},
                        {'id': 'children', 'label': '⭐ Children (9-12)'},
                        {'id': 'teen', 'label': '🔥 Teen (13+)'},
                      ].map((f) {
                        final sel = _ageFilter == f['id'];
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () => setState(() {
                              _ageFilter = f['id']!;
                              _selectedIndex = 0;
                            }),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 7),
                              decoration: BoxDecoration(
                                color: sel
                                    ? AppColors.accentPurple.withOpacity(0.2)
                                    : AppColors.darkSurface,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: sel
                                      ? AppColors.accentPurple
                                      : AppColors.darkBorder,
                                ),
                              ),
                              child: Text(f['label']!,
                                  style: TextStyle(
                                    color: sel
                                        ? AppColors.accentPurple
                                        : Colors.white54,
                                    fontSize: 13,
                                  )),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                // Date selector row
                if (list.isNotEmpty)
                  SizedBox(
                    height: 64,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      itemCount: list.length,
                      itemBuilder: (_, i) {
                        final d = list[i];
                        final sel = _selectedIndex == i;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedIndex = i),
                          child: Container(
                            width: 52,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: sel
                                  ? AppColors.accentPurple
                                  : AppColors.darkSurface,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: sel
                                    ? AppColors.accentPurple
                                    : AppColors.darkBorder,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(_monthAbbr(d.date),
                                    style: TextStyle(
                                      color: sel ? Colors.white70 : Colors.white38,
                                      fontSize: 10,
                                    )),
                                Text('${d.date.day}',
                                    style: TextStyle(
                                      color: sel ? Colors.white : Colors.white70,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    )),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                // Devotional content
                if (dev != null)
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: _DevotionalCard(
                        dev: dev,
                        canEdit: _canEdit,
                        onEdit: () => _showForm(dev),
                        onDelete: () => _delete(dev),
                      ),
                    ),
                  )
                else
                  const Expanded(
                    child: Center(
                        child: Text('No devotionals found.',
                            style: TextStyle(color: Colors.white38))),
                  ),
              ],
            ),
    );
  }

  String _monthAbbr(DateTime d) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return months[d.month - 1];
  }

  void _showForm(_Devotional? existing) {
    final titleC = TextEditingController(text: existing?.title);
    final scriptureC = TextEditingController(text: existing?.scripture);
    final verseC = TextEditingController(text: existing?.verse);
    final bodyC = TextEditingController(text: existing?.body);
    final reflectionC = TextEditingController(text: existing?.reflection);
    final prayerC = TextEditingController(text: existing?.prayer);
    String ageGroup = existing?.ageGroup ?? 'all';
    DateTime date = existing?.date ?? DateTime.now();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkSurface2,
        title: Text(existing == null ? 'Add Devotional' : 'Edit Devotional',
            style: const TextStyle(color: Colors.white)),
        content: StatefulBuilder(builder: (ctx2, setSt) {
          return SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                _DarkField(controller: titleC, label: 'Title *'),
                const SizedBox(height: 10),
                _DarkField(controller: scriptureC, label: 'Scripture Reference'),
                const SizedBox(height: 10),
                _DarkField(controller: verseC, label: 'Bible Verse', maxLines: 3),
                const SizedBox(height: 10),
                _DarkField(controller: bodyC, label: 'Devotional Body', maxLines: 6),
                const SizedBox(height: 10),
                _DarkField(controller: reflectionC, label: 'Reflection Question', maxLines: 2),
                const SizedBox(height: 10),
                _DarkField(controller: prayerC, label: 'Prayer', maxLines: 3),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: ageGroup,
                  dropdownColor: AppColors.darkSurface2,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Age Group',
                    labelStyle: TextStyle(color: Colors.white54),
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.darkBorder)),
                    border: OutlineInputBorder(borderSide: BorderSide(color: AppColors.darkBorder)),
                  ),
                  items: ['all', 'little', 'children', 'teen']
                      .map((a) => DropdownMenuItem(value: a, child: Text(a)))
                      .toList(),
                  onChanged: (v) => setSt(() => ageGroup = v ?? 'all'),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: date,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                      builder: (_, child) => Theme(
                        data: ThemeData.dark().copyWith(
                          colorScheme: const ColorScheme.dark(
                              primary: AppColors.accentPurple),
                        ),
                        child: child!,
                      ),
                    );
                    if (picked != null) setSt(() => date = picked);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.darkSurface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.darkBorder),
                    ),
                    child: Row(children: [
                      const Icon(Icons.calendar_today,
                          size: 14, color: Colors.white54),
                      const SizedBox(width: 8),
                      Text('${date.day}/${date.month}/${date.year}',
                          style: const TextStyle(color: Colors.white70)),
                    ]),
                  ),
                ),
              ]),
            ),
          );
        }),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentPurple),
            child: Text(existing == null ? 'Publish' : 'Save'),
            onPressed: () async {
              if (titleC.text.trim().isEmpty) return;
              final dev = _Devotional(
                id: existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                title: titleC.text.trim(),
                date: date,
                scripture: scriptureC.text.trim(),
                verse: verseC.text.trim(),
                body: bodyC.text.trim(),
                reflection: reflectionC.text.trim(),
                prayer: prayerC.text.trim(),
                ageGroup: ageGroup,
              );
              final list = List<_Devotional>.from(_devotionals);
              if (existing == null) {
                list.insert(0, dev);
              } else {
                final idx = list.indexWhere((d) => d.id == dev.id);
                if (idx >= 0) list[idx] = dev;
              }
              await _save(list);
              Navigator.pop(ctx);
              _load();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _delete(_Devotional dev) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkSurface2,
        title: const Text('Delete Devotional?',
            style: TextStyle(color: Colors.white)),
        content: Text('Delete "${dev.title}"?',
            style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel',
                  style: TextStyle(color: Colors.white54))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok == true) {
      final list = List<_Devotional>.from(_devotionals)
        ..removeWhere((d) => d.id == dev.id);
      await _save(list);
      _load();
    }
  }
}

// ── Devotional Card ────────────────────────────────────────────────────────────
class _DevotionalCard extends StatefulWidget {
  final _Devotional dev;
  final bool canEdit;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _DevotionalCard({
    required this.dev,
    required this.canEdit,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<_DevotionalCard> createState() => _DevotionalCardState();
}

class _DevotionalCardState extends State<_DevotionalCard> {
  bool _prayerExpanded = false;

  @override
  Widget build(BuildContext context) {
    final dev = widget.dev;
    final ageLabel = _ageLabel(dev.ageGroup);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title + date
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: AppColors.accentGradient,
            borderRadius: BorderRadius.circular(14),
            boxShadow: AppColors.glowPurple(radius: 20, opacity: 0.2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                if (ageLabel != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(ageLabel,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 11)),
                  ),
                const Spacer(),
                if (widget.canEdit) ...[
                  GestureDetector(
                    onTap: widget.onEdit,
                    child: const Icon(Icons.edit_outlined,
                        color: Colors.white70, size: 18),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: widget.onDelete,
                    child: const Icon(Icons.delete_outline,
                        color: Colors.white54, size: 18),
                  ),
                ],
              ]),
              Text(
                _formatDate(dev.date),
                style: const TextStyle(
                    color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(dev.title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 22)),
              const SizedBox(height: 4),
              Text(dev.scripture,
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 13)),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Scripture verse
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.accentPurple.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: AppColors.accentPurple.withOpacity(0.25)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('❝ ',
                  style: TextStyle(
                      color: AppColors.accentPurple, fontSize: 20)),
              Expanded(
                  child: Text(dev.verse,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontStyle: FontStyle.italic,
                          height: 1.5))),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Body
        _Section(title: '📖 Devotional', child: Text(dev.body,
            style: const TextStyle(
                color: Colors.white70, fontSize: 14, height: 1.7))),
        const SizedBox(height: 12),

        // Reflection
        if (dev.reflection.isNotEmpty)
          _Section(
            title: '💬 Reflection',
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.accentGold.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: AppColors.accentGold.withOpacity(0.3)),
              ),
              child: Text(dev.reflection,
                  style: const TextStyle(
                      color: AppColors.accentGold, fontSize: 14)),
            ),
          ),
        const SizedBox(height: 12),

        // Prayer (collapsible)
        if (dev.prayer.isNotEmpty)
          GestureDetector(
            onTap: () =>
                setState(() => _prayerExpanded = !_prayerExpanded),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.darkSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.darkBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Text('🙏 ',
                        style: TextStyle(fontSize: 16)),
                    const Text('Prayer',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14)),
                    const Spacer(),
                    Icon(
                      _prayerExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Colors.white38,
                    ),
                  ]),
                  if (_prayerExpanded) ...[
                    const SizedBox(height: 10),
                    Text(dev.prayer,
                        style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            height: 1.6)),
                  ],
                ],
              ),
            ),
          ),
        const SizedBox(height: 30),
      ],
    );
  }

  String _formatDate(DateTime d) {
    const months = ['January','February','March','April','May','June',
        'July','August','September','October','November','December'];
    const days = ['Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'];
    return '${days[d.weekday - 1]}, ${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  String? _ageLabel(String ag) {
    switch (ag) {
      case 'little': return '🌱 Ages 5–8';
      case 'children':   return '⭐ Ages 9–12';
      case 'teen':   return '🔥 Teen';
      default:       return null;
    }
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;

  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: AppColors.accentPurple,
                  fontWeight: FontWeight.bold,
                  fontSize: 14)),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _DarkField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final int maxLines;

  const _DarkField(
      {required this.controller, required this.label, this.maxLines = 1});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: AppColors.darkSurface,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.accentPurple),
        ),
      ),
    );
  }
}

// ── Model ──────────────────────────────────────────────────────────────────────
class _Devotional {
  final String id;
  final String title;
  final DateTime date;
  final String scripture;
  final String verse;
  final String body;
  final String reflection;
  final String prayer;
  final String ageGroup; // all, little, children, teen

  const _Devotional({
    required this.id,
    required this.title,
    required this.date,
    required this.scripture,
    required this.verse,
    required this.body,
    required this.reflection,
    required this.prayer,
    this.ageGroup = 'all',
  });

  factory _Devotional.fromJson(Map<String, dynamic> j) => _Devotional(
    id: j['id'] as String? ?? DateTime.now().toString(),
    title: j['title'] as String? ?? '',
    date: j['date'] != null ? DateTime.parse(j['date'] as String) : DateTime.now(),
    scripture: j['scripture'] as String? ?? '',
    verse: j['verse'] as String? ?? '',
    body: j['body'] as String? ?? '',
    reflection: j['reflection'] as String? ?? '',
    prayer: j['prayer'] as String? ?? '',
    ageGroup: j['age_group'] as String? ?? 'all',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'date': date.toIso8601String(),
    'scripture': scripture,
    'verse': verse,
    'body': body,
    'reflection': reflection,
    'prayer': prayer,
    'age_group': ageGroup,
  };
}
