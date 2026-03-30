class VideoContent {
  final String id;
  final String title;
  final String description;
  final String videoUrl;
  final String thumbnailUrl;
  final String category;
  final String speaker;
  final String duration;
  final int views;
  final DateTime uploadedAt;
  final bool isPublished;
  final String youtubeUrl;
  final String audience;   // 'all', 'adults', 'children'
  final String uploadedBy;

  VideoContent({
    required this.id,
    required this.title,
    this.description = '',
    this.videoUrl = '',
    this.thumbnailUrl = '',
    this.category = 'General',
    this.speaker = '',
    this.duration = '0:00',
    this.views = 0,
    DateTime? uploadedAt,
    this.isPublished = false,
    this.youtubeUrl = '',
    this.audience = 'all',
    this.uploadedBy = '',
  }) : uploadedAt = uploadedAt ?? DateTime.now();

  factory VideoContent.fromJson(Map<String, dynamic> json) {
    return VideoContent(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      videoUrl: json['video_url'] as String? ?? json['videoUrl'] as String? ?? '',
      thumbnailUrl: json['thumbnail_url'] as String? ?? json['thumbnailUrl'] as String? ?? '',
      category: json['category'] as String? ?? 'General',
      speaker: json['speaker'] as String? ?? '',
      duration: json['duration'] as String? ?? '0:00',
      views: json['views'] as int? ?? 0,
      uploadedAt: json['uploaded_at'] != null
          ? DateTime.parse(json['uploaded_at'] as String)
          : json['uploadedAt'] != null
              ? DateTime.parse(json['uploadedAt'] as String)
              : DateTime.now(),
      isPublished: json['is_published'] as bool? ?? json['isPublished'] as bool? ?? false,
      youtubeUrl: json['youtube_url'] as String? ?? json['youtubeUrl'] as String? ?? '',
      audience: json['audience'] as String? ?? 'all',
      uploadedBy: json['uploaded_by'] as String? ?? json['uploadedBy'] as String? ?? '',
    );
  }

  factory VideoContent.fromSupabase(Map<String, dynamic> json) => VideoContent.fromJson(json);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'video_url': videoUrl,
      'thumbnail_url': thumbnailUrl,
      'category': category,
      'speaker': speaker,
      'duration': duration,
      'views': views,
      'uploaded_at': uploadedAt.toIso8601String(),
      'is_published': isPublished,
      'youtube_url': youtubeUrl,
      'audience': audience,
      'uploaded_by': uploadedBy,
    };
  }

  Map<String, dynamic> toSupabase() => toJson();

  VideoContent copyWith({
    String? title, String? description, String? videoUrl, String? thumbnailUrl,
    String? category, String? speaker, String? duration, int? views,
    DateTime? uploadedAt, bool? isPublished, String? youtubeUrl,
    String? audience, String? uploadedBy,
  }) {
    return VideoContent(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      videoUrl: videoUrl ?? this.videoUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      category: category ?? this.category,
      speaker: speaker ?? this.speaker,
      duration: duration ?? this.duration,
      views: views ?? this.views,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      isPublished: isPublished ?? this.isPublished,
      youtubeUrl: youtubeUrl ?? this.youtubeUrl,
      audience: audience ?? this.audience,
      uploadedBy: uploadedBy ?? this.uploadedBy,
    );
  }
}
