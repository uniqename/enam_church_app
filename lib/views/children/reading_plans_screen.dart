import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../models/reading_plan.dart';
import '../../utils/colors.dart';

class ReadingPlansScreen extends StatefulWidget {
  const ReadingPlansScreen({super.key});

  @override
  State<ReadingPlansScreen> createState() => _ReadingPlansScreenState();
}

class _ReadingPlansScreenState extends State<ReadingPlansScreen> {
  List<ReadingPlan> _plans = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('reading_plans_progress');
    final Map<String, dynamic> savedProgress =
        raw != null ? jsonDecode(raw) as Map<String, dynamic> : {};

    final plans = _defaultPlans();
    for (final plan in plans) {
      final saved = savedProgress[plan.id];
      if (saved != null) {
        plan.completedDays = saved['completed_days'] as int? ?? 0;
        plan.started = saved['started'] as bool? ?? false;
      }
    }

    setState(() {
      _plans = plans;
      _isLoading = false;
    });
  }

  Future<void> _savePlanProgress(ReadingPlan plan) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('reading_plans_progress');
    final Map<String, dynamic> all =
        raw != null ? jsonDecode(raw) as Map<String, dynamic> : {};
    all[plan.id] = {
      'completed_days': plan.completedDays,
      'started': plan.started,
    };
    await prefs.setString('reading_plans_progress', jsonEncode(all));
  }

  List<ReadingPlan> _defaultPlans() {
    return [
      ReadingPlan(
        id: 'creation_week',
        title: 'The Creation Week',
        description:
            'Discover how God made everything in 7 days! Follow along and learn what He created each day.',
        imageEmoji: '🌍',
        totalDays: 7,
        days: [
          ReadingPlanDay(
            day: 1,
            title: 'In the Beginning',
            scripture: 'Genesis 1:1-5',
            passage:
                'In the beginning God created the heavens and the earth. Now the earth was formless and empty, darkness was over the surface of the deep, and the Spirit of God was hovering over the waters. And God said, "Let there be light," and there was light.',
            reflection:
                'God started with nothing and made everything! He made light on the very first day. What\'s your favorite thing God made?',
          ),
          ReadingPlanDay(
            day: 2,
            title: 'Sky and Water',
            scripture: 'Genesis 1:6-8',
            passage:
                'And God said, "Let there be a vault between the waters to separate water from water." So God made the vault and separated the water under the vault from the water above it. And it was so. God called the vault "sky."',
            reflection:
                'God separated the sky from the water. Next time you look up at the sky, remember God made it just for you!',
          ),
          ReadingPlanDay(
            day: 3,
            title: 'Land and Plants',
            scripture: 'Genesis 1:9-13',
            passage:
                'And God said, "Let the water under the sky be gathered to one place, and let dry ground appear." And it was so. God called the dry ground "land," and the gathered waters he called "seas." And God saw that it was good.',
            reflection:
                'God made all the plants and trees! Every flower and fruit came from His amazing plan.',
          ),
          ReadingPlanDay(
            day: 4,
            title: 'Sun, Moon and Stars',
            scripture: 'Genesis 1:14-19',
            passage:
                'And God said, "Let there be lights in the vault of the sky to separate the day from the night." He also made the stars. God set them in the vault of the sky to give light on the earth.',
            reflection:
                'God put the sun, moon, and billions of stars in the sky! He thought of everything we would need.',
          ),
          ReadingPlanDay(
            day: 5,
            title: 'Birds and Sea Creatures',
            scripture: 'Genesis 1:20-23',
            passage:
                'And God said, "Let the water teem with living creatures, and let birds fly above the earth across the vault of the sky." So God created the great creatures of the sea and every living thing with which the water teems.',
            reflection:
                'God filled the oceans and skies with amazing animals! What\'s your favorite ocean animal or bird?',
          ),
          ReadingPlanDay(
            day: 6,
            title: 'Animals and People',
            scripture: 'Genesis 1:24-27',
            passage:
                'So God created mankind in his own image, in the image of God he created them; male and female he created them.',
            reflection:
                'You were made in God\'s image — that means you are very special! God loves you more than anything He created.',
          ),
          ReadingPlanDay(
            day: 7,
            title: 'God\'s Rest',
            scripture: 'Genesis 2:1-3',
            passage:
                'By the seventh day God had finished the work he had been doing; so on the seventh day he rested from all his work. Then God blessed the seventh day and made it holy.',
            reflection:
                'God rested on the seventh day and called it holy. Sunday is a special day to worship God and rest with your family!',
          ),
        ],
      ),
      ReadingPlan(
        id: 'jesus_miracles',
        title: 'Jesus\' Amazing Miracles',
        description:
            'Read about 5 incredible things Jesus did that only God could do!',
        imageEmoji: '✨',
        totalDays: 5,
        days: [
          ReadingPlanDay(
            day: 1,
            title: 'Water into Wine',
            scripture: 'John 2:1-11',
            passage:
                'Jesus said to the servants, "Fill the jars with water." They filled them to the brim. Then he told them, "Now draw some out and take it to the master of the banquet." The master of the banquet tasted the water that had been turned into wine.',
            reflection:
                'Jesus turned plain water into delicious wine! This was His first miracle. He can turn ordinary things into something amazing — even your ordinary day!',
          ),
          ReadingPlanDay(
            day: 2,
            title: 'Feeding 5,000',
            scripture: 'John 6:1-13',
            passage:
                'Jesus then took the loaves, gave thanks, and distributed to those who were seated as much as they wanted. He did the same with the fish. When they had all had enough to eat, he said to his disciples, "Gather the pieces that are left over. Let nothing be wasted." So they gathered them and filled twelve baskets.',
            reflection:
                'With just 5 loaves and 2 fish, Jesus fed over 5,000 people — AND there were leftovers! When you give what little you have to God, He can multiply it!',
          ),
          ReadingPlanDay(
            day: 3,
            title: 'Walking on Water',
            scripture: 'Matthew 14:25-31',
            passage:
                '"Lord, if it\'s you," Peter replied, "tell me to come to you on the water." "Come," he said. Then Peter got down out of the boat, walked on the water and came toward Jesus.',
            reflection:
                'Jesus walked on water — and so did Peter when he kept his eyes on Jesus! When we focus on Jesus instead of our problems, He holds us up.',
          ),
          ReadingPlanDay(
            day: 4,
            title: 'Healing the Blind',
            scripture: 'John 9:1-11',
            passage:
                '"While I am in the world, I am the light of the world." After saying this, he spit on the ground, made some mud with the saliva, and put it on the man\'s eyes. "Go," he told him, "wash in the Pool of Siloam." So the man went and washed, and came home seeing.',
            reflection:
                'The man had been blind his whole life, but Jesus healed him! Jesus is the light of the world — He can help us see things clearly too.',
          ),
          ReadingPlanDay(
            day: 5,
            title: 'Lazarus Raised',
            scripture: 'John 11:38-44',
            passage:
                'Jesus called in a loud voice, "Lazarus, come out!" The dead man came out, his hands and feet wrapped with strips of linen, and a cloth around his face. Jesus said to them, "Take off the grave clothes and let him go."',
            reflection:
                'Jesus brought Lazarus back to life! This shows that Jesus has power even over death. One day He will raise us all to live with Him forever!',
          ),
        ],
      ),
      ReadingPlan(
        id: 'heroes_of_faith',
        title: 'Heroes of Faith',
        description:
            'Meet amazing Bible heroes who trusted God even when things were hard!',
        imageEmoji: '🦸',
        totalDays: 7,
        days: [
          ReadingPlanDay(
            day: 1,
            title: 'Noah\'s Big Boat',
            scripture: 'Genesis 6:13-14, 7:1',
            passage:
                'So God said to Noah, "I am going to put an end to all people... So make yourself an ark." The Lord then said to Noah, "Go into the ark, you and your whole family, because I have found you righteous in this generation."',
            reflection:
                'Noah obeyed God even when everyone thought he was crazy! When God asks you to do something, be brave like Noah.',
          ),
          ReadingPlanDay(
            day: 2,
            title: 'Abraham\'s Trust',
            scripture: 'Genesis 12:1-4',
            passage:
                'The Lord had said to Abram, "Go from your country, your people and your father\'s household to the land I will show you." So Abram went, as the Lord had told him.',
            reflection:
                'Abraham left everything familiar because God asked him to. Trusting God even when we don\'t know the plan takes great faith!',
          ),
          ReadingPlanDay(
            day: 3,
            title: 'David and Goliath',
            scripture: '1 Samuel 17:45-47',
            passage:
                'David said to the Philistine, "You come against me with sword and spear and javelin, but I come against you in the name of the Lord Almighty." Reaching into his bag and taking out a stone, he slung it and struck the Philistine on the forehead.',
            reflection:
                'David wasn\'t scared of the giant because he knew God was with him. What giant problem in your life can you trust God to help you with?',
          ),
          ReadingPlanDay(
            day: 4,
            title: 'Daniel in the Lion\'s Den',
            scripture: 'Daniel 6:19-22',
            passage:
                'At the first light of dawn, the king got up and hurried to the lions\' den. He called to Daniel, "Daniel, servant of the living God, has your God, whom you serve continually, been able to rescue you from the lions?" Daniel answered, "My God sent his angel, and he shut the mouths of the lions."',
            reflection:
                'Daniel kept praying even when it was dangerous. God protected him completely! Keep praying no matter what.',
          ),
          ReadingPlanDay(
            day: 5,
            title: 'Esther\'s Courage',
            scripture: 'Esther 4:14, 5:2',
            passage:
                '"Who knows but that you have come to your royal position for such a time as this?" When the king saw Queen Esther standing in the court, he was pleased with her and held out to her the golden scepter.',
            reflection:
                'Esther was brave enough to speak up for her people. Maybe God placed you exactly where you are for a special purpose too!',
          ),
          ReadingPlanDay(
            day: 6,
            title: 'Elijah and the Fire',
            scripture: '1 Kings 18:36-39',
            passage:
                'Then the fire of the Lord fell and burned up the sacrifice, the wood, the stones and the soil, and also licked up the water in the trench. When all the people saw this, they fell prostrate and cried: "The Lord — he is God!"',
            reflection:
                'Elijah prayed and God sent fire from heaven! God still answers bold prayers today. What big prayer do you want to pray?',
          ),
          ReadingPlanDay(
            day: 7,
            title: 'Paul\'s Transformation',
            scripture: 'Acts 9:3-6',
            passage:
                'As he neared Damascus on his journey, suddenly a light from heaven flashed around him. He fell to the ground and heard a voice say to him, "Saul, Saul, why do you persecute me?" "Who are you, Lord?" Saul asked. "I am Jesus, whom you are persecuting."',
            reflection:
                'Paul went from hurting Christians to being one of the greatest! It\'s never too late to change and follow Jesus. God can transform anyone!',
          ),
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reading Plans'),
        backgroundColor: AppColors.childBlue,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.childBlue, AppColors.childPurple],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Column(
                      children: [
                        Text('📖', style: TextStyle(fontSize: 48)),
                        SizedBox(height: 8),
                        Text(
                          'Bible Reading Plans',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Earn badges as you read!',
                          style: TextStyle(fontSize: 14, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ..._plans.map((plan) => _PlanCard(
                        plan: plan,
                        onProgress: () async {
                          await _savePlanProgress(plan);
                          setState(() {});
                        },
                      )),
                ],
              ),
            ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final ReadingPlan plan;
  final VoidCallback onProgress;
  const _PlanCard({required this.plan, required this.onProgress});

  @override
  Widget build(BuildContext context) {
    final earned = plan.earnedBadges;
    final next = plan.nextBadge;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => _ReadingPlanDetail(
              plan: plan,
              onProgress: onProgress,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(plan.imageEmoji,
                      style: const TextStyle(fontSize: 40)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plan.title,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${plan.totalDays}-Day Plan',
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  if (plan.isCompleted)
                    const Text('👑',
                        style: TextStyle(fontSize: 28)),
                ],
              ),
              const SizedBox(height: 12),
              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: plan.progress,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.childBlue),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${plan.completedDays} / ${plan.totalDays} days',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              if (earned.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Badges: ',
                        style: TextStyle(fontSize: 12)),
                    ...earned.map((b) => Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Tooltip(
                            message: b.name,
                            child: Text(b.emoji,
                                style: const TextStyle(fontSize: 20)),
                          ),
                        )),
                  ],
                ),
              ],
              if (next != null && !plan.isCompleted) ...[
                const SizedBox(height: 4),
                Text(
                  'Next badge: ${next.emoji} ${next.name} at ${next.daysRequired} days',
                  style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ReadingPlanDetail extends StatefulWidget {
  final ReadingPlan plan;
  final VoidCallback onProgress;
  const _ReadingPlanDetail(
      {required this.plan, required this.onProgress});

  @override
  State<_ReadingPlanDetail> createState() => _ReadingPlanDetailState();
}

class _ReadingPlanDetailState extends State<_ReadingPlanDetail> {
  void _markDayComplete(ReadingPlanDay day) async {
    if (day.completed) return;
    setState(() {
      day.completed = true;
      widget.plan.completedDays =
          widget.plan.days.where((d) => d.completed).length;
      widget.plan.started = true;
    });
    widget.onProgress();

    final earned = widget.plan.earnedBadges;
    // Check if a new badge was just earned
    if (earned.isNotEmpty) {
      final latest = earned.last;
      if (latest.daysRequired == widget.plan.completedDays) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Badge Earned! 🎉'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(latest.emoji,
                      style: const TextStyle(fontSize: 64)),
                  const SizedBox(height: 8),
                  Text(
                    latest.name,
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(latest.description),
                ],
              ),
              actions: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.childBlue,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Awesome!'),
                ),
              ],
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.plan.title),
        backgroundColor: AppColors.childBlue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header with badges
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.childBlue, AppColors.childPurple],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(widget.plan.imageEmoji,
                      style: const TextStyle(fontSize: 48)),
                  const SizedBox(height: 8),
                  Text(
                    widget.plan.title,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.plan.description,
                    style: const TextStyle(
                        fontSize: 13, color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: widget.plan.progress,
                      backgroundColor: Colors.white30,
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.white),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.plan.completedDays} / ${widget.plan.totalDays} days completed',
                    style: const TextStyle(
                        fontSize: 12, color: Colors.white70),
                  ),
                  if (widget.plan.earnedBadges.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: widget.plan.earnedBadges
                          .map((b) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                child: Column(
                                  children: [
                                    Text(b.emoji,
                                        style: const TextStyle(fontSize: 24)),
                                    Text(b.name,
                                        style: const TextStyle(
                                            fontSize: 9,
                                            color: Colors.white70)),
                                  ],
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
            ...widget.plan.days.map((day) => _DayTile(
                  day: day,
                  onComplete: () => _markDayComplete(day),
                )),
          ],
        ),
      ),
    );
  }
}

class _DayTile extends StatelessWidget {
  final ReadingPlanDay day;
  final VoidCallback onComplete;
  const _DayTile({required this.day, required this.onComplete});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: day.completed ? 1 : 3,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => _DayReadingScreen(
              day: day,
              onComplete: onComplete,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: day.completed
                      ? AppColors.childGreen
                      : AppColors.childBlue.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: day.completed
                      ? const Icon(Icons.check,
                          color: Colors.white, size: 20)
                      : Text(
                          '${day.day}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.childBlue),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      day.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: day.completed
                            ? Colors.grey
                            : Colors.black87,
                      ),
                    ),
                    Text(
                      day.scripture,
                      style: const TextStyle(
                          fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Icon(
                day.completed
                    ? Icons.check_circle
                    : Icons.chevron_right,
                color: day.completed
                    ? AppColors.childGreen
                    : Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DayReadingScreen extends StatelessWidget {
  final ReadingPlanDay day;
  final VoidCallback onComplete;
  const _DayReadingScreen(
      {required this.day, required this.onComplete});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Day ${day.day}: ${day.title}'),
        backgroundColor: AppColors.childBlue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Scripture reference
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.childBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '📖 ${day.scripture}',
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.childBlue),
              ),
            ),
            const SizedBox(height: 20),
            // Passage
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Text(
                day.passage,
                style: const TextStyle(
                    fontSize: 16,
                    height: 1.8,
                    fontStyle: FontStyle.italic),
              ),
            ),
            const SizedBox(height: 24),
            // Reflection
            const Text(
              '💭 Think About It',
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.childYellow.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppColors.childYellow.withValues(alpha: 0.4)),
              ),
              child: Text(
                day.reflection,
                style:
                    const TextStyle(fontSize: 15, height: 1.6),
              ),
            ),
            const SizedBox(height: 32),
            if (!day.completed)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    onComplete();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.childGreen,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    '✅ Mark as Complete!',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.childGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: AppColors.childGreen),
                    SizedBox(width: 8),
                    Text('Completed!',
                        style: TextStyle(
                            color: AppColors.childGreen,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
