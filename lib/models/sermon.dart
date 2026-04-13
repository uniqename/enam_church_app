import 'package:uuid/uuid.dart';

class Sermon {
  final String id;
  final String title;
  final String speaker;
  final DateTime date;
  final String filePath; // local path
  final String fileUrl;  // remote URL (Supabase Storage)
  final String fileType; // 'audio' or 'video'
  final String description;
  final String audience; // 'all', 'adults'
  final DateTime createdAt;

  const Sermon({
    required this.id,
    required this.title,
    required this.speaker,
    required this.date,
    required this.filePath,
    required this.fileUrl,
    required this.fileType,
    required this.description,
    this.audience = 'all',
    required this.createdAt,
  });

  factory Sermon.create({
    required String title,
    required String speaker,
    required DateTime date,
    required String filePath,
    String fileUrl = '',
    required String fileType,
    String description = '',
    String audience = 'all',
  }) {
    return Sermon(
      id: const Uuid().v4(),
      title: title,
      speaker: speaker,
      date: date,
      filePath: filePath,
      fileUrl: fileUrl,
      fileType: fileType,
      description: description,
      audience: audience,
      createdAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'speaker': speaker,
        'date': date.toIso8601String(),
        'file_path': filePath,
        'file_url': fileUrl,
        'file_type': fileType,
        'description': description,
        'audience': audience,
        'created_at': createdAt.toIso8601String(),
      };

  factory Sermon.fromJson(Map<String, dynamic> json) => Sermon(
        id: json['id'] as String,
        title: json['title'] as String,
        speaker: json['speaker'] as String? ?? json['preacher'] as String? ?? '',
        date: DateTime.parse(json['date'] as String? ?? json['sermon_date'] as String? ?? DateTime.now().toIso8601String()),
        filePath: json['file_path'] as String? ?? '',
        fileUrl: json['file_url'] as String? ?? json['video_url'] as String? ?? json['audio_url'] as String? ?? '',
        fileType: json['file_type'] as String? ?? (json['video_url'] != null && (json['video_url'] as String).isNotEmpty ? 'video' : 'audio'),
        description: json['description'] as String? ?? '',
        audience: json['audience'] as String? ?? 'all',
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  // Maps to the actual Supabase sermons table schema
  Map<String, dynamic> toSupabase() => {
        'id': id,
        'title': title,
        'preacher': speaker,
        'description': description,
        'audio_url': fileType == 'audio' ? fileUrl : '',
        'video_url': fileType == 'video' ? fileUrl : '',
        'sermon_date': date.toIso8601String(),
        'series': audience, // reuse series field for audience tag
        'created_at': createdAt.toIso8601String(),
      };

  factory Sermon.fromSupabase(Map<String, dynamic> json) => Sermon(
        id: json['id'] as String,
        title: json['title'] as String? ?? '',
        speaker: json['preacher'] as String? ?? '',
        date: json['sermon_date'] != null
            ? DateTime.parse(json['sermon_date'] as String)
            : DateTime.now(),
        filePath: '',
        fileUrl: (json['video_url'] as String? ?? '').isNotEmpty
            ? json['video_url'] as String
            : json['audio_url'] as String? ?? '',
        fileType: (json['video_url'] as String? ?? '').isNotEmpty ? 'video' : 'audio',
        description: json['description'] as String? ?? '',
        audience: json['series'] as String? ?? 'all',
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : DateTime.now(),
      );

  Sermon copyWith({
    String? title,
    String? speaker,
    DateTime? date,
    String? filePath,
    String? fileUrl,
    String? fileType,
    String? description,
    String? audience,
  }) =>
      Sermon(
        id: id,
        title: title ?? this.title,
        speaker: speaker ?? this.speaker,
        date: date ?? this.date,
        filePath: filePath ?? this.filePath,
        fileUrl: fileUrl ?? this.fileUrl,
        fileType: fileType ?? this.fileType,
        description: description ?? this.description,
        audience: audience ?? this.audience,
        createdAt: createdAt,
      );
}
