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

  const VideoContent({
    required this.id,
    required this.title,
    required this.description,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.category,
    required this.speaker,
    required this.duration,
    required this.views,
    required this.uploadedAt,
    required this.isPublished,
  });

  factory VideoContent.fromSupabase(Map<String, dynamic> json) {
    return VideoContent(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      videoUrl: json['video_url'] as String? ?? '',
      thumbnailUrl: json['thumbnail_url'] as String? ?? '',
      category: json['category'] as String? ?? 'General',
      speaker: json['speaker'] as String? ?? '',
      duration: json['duration'] as String? ?? '0:00',
      views: json['views'] as int? ?? 0,
      uploadedAt: json['uploaded_at'] != null
          ? DateTime.parse(json['uploaded_at'] as String)
          : DateTime.now(),
      isPublished: json['is_published'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toSupabase() {
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
    };
  }
}
