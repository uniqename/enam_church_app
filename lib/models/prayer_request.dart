class PrayerRequest {
  final int id;
  final String title;
  final String member;
  final String request;
  final String category;
  final String status;
  final String date;
  final bool private;
  final int responses;

  PrayerRequest({
    required this.id,
    required this.title,
    required this.member,
    required this.request,
    required this.category,
    required this.status,
    required this.date,
    required this.private,
    required this.responses,
  });
}
