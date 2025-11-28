class KidsLesson {
  final int id;
  final String title;
  final String content;
  final String duration;
  final String age;
  bool completed;

  KidsLesson({
    required this.id,
    required this.title,
    required this.content,
    required this.duration,
    required this.age,
    this.completed = false,
  });
}
