class ChildGame {
  final int id;
  final String title;
  final String description;
  final String difficulty;
  bool completed;

  ChildGame({
    required this.id,
    required this.title,
    required this.description,
    required this.difficulty,
    this.completed = false,
  });
}
