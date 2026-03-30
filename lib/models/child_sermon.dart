class ChildSermon {
  final String id;
  final String title;
  final String speaker;
  final DateTime date;
  final String duration;
  final int views;
  final String videoUrl;

  const ChildSermon({
    required this.id,
    required this.title,
    required this.speaker,
    required this.date,
    required this.duration,
    required this.views,
    required this.videoUrl,
  });

  factory ChildSermon.fromSupabase(Map<String, dynamic> json) {
    return ChildSermon(
      id: json['id'] as String,
      title: json['title'] as String,
      speaker: json['speaker'] as String? ?? '',
      date: DateTime.parse(json['date'] as String),
      duration: json['duration'] as String? ?? '5:00',
      views: json['views'] as int? ?? 0,
      videoUrl: json['video_url'] as String? ?? '',
    );
  }

  Map<String, dynamic> toSupabase() {
    return {
      'id': id,
      'title': title,
      'speaker': speaker,
      'date': date.toIso8601String().split('T')[0],
      'duration': duration,
      'views': views,
      'video_url': videoUrl,
    };
  }
}
