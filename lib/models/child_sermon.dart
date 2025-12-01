class ChildSermon {
  final int id;
  final String title;
  final String speaker;
  final String date;
  final String duration;
  final int views;
  final String videoUrl; // Added for YouTube links

  ChildSermon({
    required this.id,
    required this.title,
    required this.speaker,
    required this.date,
    required this.duration,
    required this.views,
    this.videoUrl = '',
  });
}
