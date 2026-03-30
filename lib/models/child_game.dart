class ChildGame {
  final String id;
  final String title;
  final String description;
  final String difficulty;
  final bool completed;

  const ChildGame({
    required this.id,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.completed,
  });

  factory ChildGame.fromSupabase(Map<String, dynamic> json) {
    return ChildGame(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      difficulty: json['difficulty'] as String? ?? 'Easy',
      completed: json['completed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toSupabase() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'difficulty': difficulty,
      'completed': completed,
    };
  }

  ChildGame copyWith({bool? completed}) {
    return ChildGame(
      id: id,
      title: title,
      description: description,
      difficulty: difficulty,
      completed: completed ?? this.completed,
    );
  }
}
