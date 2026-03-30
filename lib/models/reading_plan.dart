class ReadingPlanDay {
  final int day;
  final String title;
  final String scripture; // e.g. "John 3:16-17"
  final String passage;
  final String reflection;
  bool completed;

  ReadingPlanDay({
    required this.day,
    required this.title,
    required this.scripture,
    required this.passage,
    required this.reflection,
    this.completed = false,
  });

  factory ReadingPlanDay.fromJson(Map<String, dynamic> json) {
    return ReadingPlanDay(
      day: json['day'] as int,
      title: json['title'] as String,
      scripture: json['scripture'] as String,
      passage: json['passage'] as String,
      reflection: json['reflection'] as String,
      completed: json['completed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'day': day,
        'title': title,
        'scripture': scripture,
        'passage': passage,
        'reflection': reflection,
        'completed': completed,
      };
}

class ReadingPlanBadge {
  final String id;
  final String name;
  final String emoji;
  final String description;
  final int daysRequired; // complete this many days to earn badge

  const ReadingPlanBadge({
    required this.id,
    required this.name,
    required this.emoji,
    required this.description,
    required this.daysRequired,
  });
}

class ReadingPlan {
  final String id;
  final String title;
  final String description;
  final String imageEmoji;
  final int totalDays;
  final List<ReadingPlanDay> days;
  int completedDays;
  bool started;
  DateTime? startDate;

  ReadingPlan({
    required this.id,
    required this.title,
    required this.description,
    required this.imageEmoji,
    required this.totalDays,
    required this.days,
    this.completedDays = 0,
    this.started = false,
    this.startDate,
  });

  double get progress =>
      totalDays == 0 ? 0 : completedDays / totalDays;

  bool get isCompleted => completedDays >= totalDays;

  List<ReadingPlanBadge> get earnedBadges {
    final all = ReadingPlanBadge.allBadges;
    return all.where((b) => completedDays >= b.daysRequired).toList();
  }

  ReadingPlanBadge? get nextBadge {
    final all = ReadingPlanBadge.allBadges;
    for (final b in all) {
      if (completedDays < b.daysRequired) return b;
    }
    return null;
  }

  factory ReadingPlan.fromJson(Map<String, dynamic> json) {
    return ReadingPlan(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      imageEmoji: json['image_emoji'] as String? ?? '📖',
      totalDays: json['total_days'] as int,
      days: (json['days'] as List<dynamic>?)
              ?.map((d) => ReadingPlanDay.fromJson(d as Map<String, dynamic>))
              .toList() ??
          [],
      completedDays: json['completed_days'] as int? ?? 0,
      started: json['started'] as bool? ?? false,
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'image_emoji': imageEmoji,
        'total_days': totalDays,
        'days': days.map((d) => d.toJson()).toList(),
        'completed_days': completedDays,
        'started': started,
        'start_date': startDate?.toIso8601String(),
      };
}

extension ReadingPlanBadgeAll on ReadingPlanBadge {
  static List<ReadingPlanBadge> get allBadges => [
        const ReadingPlanBadge(
          id: 'seedling',
          name: 'Seedling',
          emoji: '🌱',
          description: 'Completed your first day!',
          daysRequired: 1,
        ),
        const ReadingPlanBadge(
          id: 'sprout',
          name: 'Sprout',
          emoji: '🌿',
          description: 'Read for 3 days',
          daysRequired: 3,
        ),
        const ReadingPlanBadge(
          id: 'flame',
          name: 'On Fire',
          emoji: '🔥',
          description: 'Read for 7 days',
          daysRequired: 7,
        ),
        const ReadingPlanBadge(
          id: 'star',
          name: 'Star Reader',
          emoji: '⭐',
          description: 'Read for 14 days',
          daysRequired: 14,
        ),
        const ReadingPlanBadge(
          id: 'crown',
          name: 'Bible Champion',
          emoji: '👑',
          description: 'Completed a full plan!',
          daysRequired: 30,
        ),
      ];
}
