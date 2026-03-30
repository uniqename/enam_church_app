class Announcement {
  final String id;
  final String title;
  final String content;
  final String priority;
  final String author;
  final DateTime date;
  final String department;
  final String status;

  const Announcement({
    required this.id,
    required this.title,
    required this.content,
    required this.priority,
    required this.author,
    required this.date,
    required this.department,
    required this.status,
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
    };
  }
}
