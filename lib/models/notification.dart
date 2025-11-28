class AppNotification {
  final int id;
  final String title;
  final String message;
  final String type;
  bool read;
  final String date;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.read = false,
    required this.date,
  });
}
