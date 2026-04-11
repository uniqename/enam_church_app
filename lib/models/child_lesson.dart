class ChildLesson {
  final String id;
  final String title;
  final String content;
  final String duration;
  final String ageRange;
  final bool completed;
  final String scriptureRef; // e.g. "Genesis 1:1-10"

  const ChildLesson({
    required this.id,
    required this.title,
    required this.content,
    required this.duration,
    required this.ageRange,
    required this.completed,
    this.scriptureRef = '',
  });

  factory ChildLesson.fromSupabase(Map<String, dynamic> json) {
    return ChildLesson(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String? ?? '',
      duration: json['duration'] as String? ?? '5 min',
      ageRange: json['age_range'] as String? ?? '5-10',
      completed: json['completed'] as bool? ?? false,
      scriptureRef: json['scripture_ref'] as String? ?? '',
    );
  }

  Map<String, dynamic> toSupabase() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'duration': duration,
      'age_range': ageRange,
      'completed': completed,
      'scripture_ref': scriptureRef,
    };
  }

  ChildLesson copyWith({bool? completed, String? scriptureRef}) {
    return ChildLesson(
      id: id,
      title: title,
      content: content,
      duration: duration,
      ageRange: ageRange,
      completed: completed ?? this.completed,
      scriptureRef: scriptureRef ?? this.scriptureRef,
    );
  }
}
