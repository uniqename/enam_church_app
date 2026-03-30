class PrayerRequest {
  final String id;
  final String title;
  final String memberName;
  final String request;
  final String category;
  final String status;
  final DateTime date;
  final bool isPrivate;
  final int responses;

  const PrayerRequest({
    required this.id,
    required this.title,
    required this.memberName,
    required this.request,
    required this.category,
    required this.status,
    required this.date,
    required this.isPrivate,
    required this.responses,
  });

  factory PrayerRequest.fromSupabase(Map<String, dynamic> json) {
    return PrayerRequest(
      id: json['id'] as String,
      title: json['title'] as String,
      memberName: json['member_name'] as String? ?? 'Anonymous',
      request: json['request'] as String,
      category: json['category'] as String? ?? 'General',
      status: json['status'] as String? ?? 'Open',
      date: DateTime.parse(json['date'] as String),
      isPrivate: json['private'] as bool? ?? false,
      responses: json['responses'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toSupabase() {
    return {
      'id': id,
      'title': title,
      'member_name': memberName,
      'request': request,
      'category': category,
      'status': status,
      'date': date.toIso8601String(),
      'private': isPrivate,
      'responses': responses,
    };
  }

  PrayerRequest copyWith({
    String? title,
    String? memberName,
    String? request,
    String? category,
    String? status,
    DateTime? date,
    bool? isPrivate,
    int? responses,
  }) {
    return PrayerRequest(
      id: id,
      title: title ?? this.title,
      memberName: memberName ?? this.memberName,
      request: request ?? this.request,
      category: category ?? this.category,
      status: status ?? this.status,
      date: date ?? this.date,
      isPrivate: isPrivate ?? this.isPrivate,
      responses: responses ?? this.responses,
    );
  }
}
