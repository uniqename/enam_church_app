class LiveStream {
  final String id;
  final String title;
  final DateTime date;
  final String time;
  final String status;
  final int viewers;
  final String category;
  final String streamUrl;

  const LiveStream({
    required this.id,
    required this.title,
    required this.date,
    required this.time,
    required this.status,
    required this.viewers,
    required this.category,
    required this.streamUrl,
  });

  factory LiveStream.fromSupabase(Map<String, dynamic> json) {
    return LiveStream(
      id: json['id'] as String,
      title: json['title'] as String,
      date: DateTime.parse(json['date'] as String),
      time: json['time'] as String,
      status: json['status'] as String? ?? 'Upcoming',
      viewers: json['viewers'] as int? ?? 0,
      category: json['category'] as String? ?? 'Worship',
      streamUrl: json['stream_url'] as String? ?? '',
    );
  }

  Map<String, dynamic> toSupabase() {
    return {
      'id': id,
      'title': title,
      'date': date.toIso8601String().split('T')[0],
      'time': time,
      'status': status,
      'viewers': viewers,
      'category': category,
      'stream_url': streamUrl,
    };
  }

  LiveStream copyWith({
    String? title,
    DateTime? date,
    String? time,
    String? status,
    int? viewers,
    String? category,
    String? streamUrl,
  }) {
    return LiveStream(
      id: id,
      title: title ?? this.title,
      date: date ?? this.date,
      time: time ?? this.time,
      status: status ?? this.status,
      viewers: viewers ?? this.viewers,
      category: category ?? this.category,
      streamUrl: streamUrl ?? this.streamUrl,
    );
  }
}
