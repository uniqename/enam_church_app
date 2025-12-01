class LiveStream {
  final int id;
  final String title;
  final String date;
  final String time;
  final String status;
  final int viewers;
  final String category;
  final String streamUrl;

  LiveStream({
    required this.id,
    required this.title,
    required this.date,
    required this.time,
    required this.status,
    required this.viewers,
    required this.category,
    this.streamUrl = '',
  });
}
