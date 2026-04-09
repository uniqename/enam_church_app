class Announcement {
  final String id;
  final String title;
  final String content;
  final String priority;
  final String author;
  final DateTime date;
  final String department;
  final String status;
  final String audience; // 'all', 'adults'
  final String mediaUrl; // image, mp3, or mp4 hosted on Supabase Storage

  const Announcement({
    required this.id,
    required this.title,
    required this.content,
    required this.priority,
    required this.author,
    required this.date,
    required this.department,
    required this.status,
    this.audience = 'all',
    this.mediaUrl = '',
  });

  factory Announcement.fromSupabase(Map<String, dynamic> json) {
    return Announcement(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String? ?? '',
      priority: json['priority'] as String? ?? 'Normal',
      author: json['author'] as String? ?? '',
      date: DateTime.parse(json['date'] as String),
      department: json['department'] as String? ?? 'General',
      status: json['status'] as String? ?? 'Published',
      audience: json['audience'] as String? ?? 'all',
      mediaUrl: json['media_url'] as String? ?? '',
    );
  }

  Map<String, dynamic> toSupabase() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'priority': priority,
      'author': author,
      'date': date.toIso8601String(),
      'department': department,
      'status': status,
      'audience': audience,
      'media_url': mediaUrl,
    };
  }

  Announcement copyWith({
    String? title,
    String? content,
    String? priority,
    String? department,
    String? status,
    String? audience,
    String? mediaUrl,
  }) => Announcement(
    id: id,
    title: title ?? this.title,
    content: content ?? this.content,
    priority: priority ?? this.priority,
    author: author,
    date: date,
    department: department ?? this.department,
    status: status ?? this.status,
    audience: audience ?? this.audience,
    mediaUrl: mediaUrl ?? this.mediaUrl,
  );
}
