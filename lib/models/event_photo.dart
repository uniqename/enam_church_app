import 'package:uuid/uuid.dart';

class EventPhoto {
  final String id;
  final String title;
  final String? description;
  final String imageUrl;
  final String uploadedBy; // user id
  final String uploaderName;
  final String department; // 'Church' for church-wide, or dept name
  final DateTime uploadedAt;
  final String? eventName;
  final String? eventDate;
  final bool isPublic;

  const EventPhoto({
    required this.id,
    required this.title,
    this.description,
    required this.imageUrl,
    required this.uploadedBy,
    required this.uploaderName,
    required this.department,
    required this.uploadedAt,
    this.eventName,
    this.eventDate,
    this.isPublic = true,
  });

  factory EventPhoto.create({
    required String title,
    String? description,
    required String imageUrl,
    required String uploadedBy,
    required String uploaderName,
    required String department,
    String? eventName,
    String? eventDate,
  }) {
    return EventPhoto(
      id: const Uuid().v4(),
      title: title,
      description: description,
      imageUrl: imageUrl,
      uploadedBy: uploadedBy,
      uploaderName: uploaderName,
      department: department,
      uploadedAt: DateTime.now(),
      eventName: eventName,
      eventDate: eventDate,
    );
  }

  factory EventPhoto.fromJson(Map<String, dynamic> json) {
    return EventPhoto(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String,
      uploadedBy: json['uploaded_by'] as String? ?? '',
      uploaderName: json['uploader_name'] as String? ?? '',
      department: json['department'] as String? ?? 'Church',
      uploadedAt: json['uploaded_at'] != null
          ? DateTime.parse(json['uploaded_at'] as String)
          : DateTime.now(),
      eventName: json['event_name'] as String?,
      eventDate: json['event_date'] as String?,
      isPublic: json['is_public'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'uploaded_by': uploadedBy,
      'uploader_name': uploaderName,
      'department': department,
      'uploaded_at': uploadedAt.toIso8601String(),
      'event_name': eventName,
      'event_date': eventDate,
      'is_public': isPublic,
    };
  }
}
