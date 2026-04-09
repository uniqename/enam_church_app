class Event {
  final String id;
  final String title;
  final DateTime date;
  final String time;
  final String location;
  final String type;
  final String status;
  final String coverUrl; // photo uploaded to Supabase Storage

  const Event({
    required this.id,
    required this.title,
    required this.date,
    required this.time,
    required this.location,
    required this.type,
    required this.status,
    this.coverUrl = '',
  });

  factory Event.fromSupabase(Map<String, dynamic> json) {
    return Event(
      id: json['id'] as String,
      title: json['title'] as String,
      date: DateTime.parse(json['date'] as String),
      time: json['time'] as String,
      location: json['location'] as String? ?? '',
      type: json['type'] as String? ?? 'General',
      status: json['status'] as String? ?? 'Upcoming',
      coverUrl: json['cover_url'] as String? ?? '',
    );
  }

  Map<String, dynamic> toSupabase() {
    return {
      'id': id,
      'title': title,
      'date': date.toIso8601String().split('T')[0],
      'time': time,
      'location': location,
      'type': type,
      'status': status,
      'cover_url': coverUrl,
    };
  }

  Event copyWith({
    String? title,
    DateTime? date,
    String? time,
    String? location,
    String? type,
    String? status,
    String? coverUrl,
  }) {
    return Event(
      id: id,
      title: title ?? this.title,
      date: date ?? this.date,
      time: time ?? this.time,
      location: location ?? this.location,
      type: type ?? this.type,
      status: status ?? this.status,
      coverUrl: coverUrl ?? this.coverUrl,
    );
  }
}
