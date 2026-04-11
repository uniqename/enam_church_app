class BannerSlideModel {
  final String id;
  final String title;
  final String subtitle;
  final String mediaUrl;   // image, mp3, mp4 — Supabase Storage
  final String mediaType;  // 'image', 'audio', 'video', 'none'
  final String linkRoute;  // optional in-app route to navigate on tap
  final bool isActive;
  final int sortOrder;
  final String audience; // 'adult' or 'children'

  const BannerSlideModel({
    required this.id,
    required this.title,
    this.subtitle = '',
    this.mediaUrl = '',
    this.mediaType = 'none',
    this.linkRoute = '',
    this.isActive = true,
    this.sortOrder = 0,
    this.audience = 'adult',
  });

  factory BannerSlideModel.fromSupabase(Map<String, dynamic> json) => BannerSlideModel(
        id: json['id'] as String,
        title: json['title'] as String? ?? '',
        subtitle: json['subtitle'] as String? ?? '',
        mediaUrl: json['media_url'] as String? ?? '',
        mediaType: json['media_type'] as String? ?? 'none',
        linkRoute: json['link_route'] as String? ?? '',
        isActive: json['is_active'] as bool? ?? true,
        sortOrder: json['sort_order'] as int? ?? 0,
        audience: json['audience'] as String? ?? 'adult',
      );

  Map<String, dynamic> toSupabase() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'media_url': mediaUrl,
        'media_type': mediaType,
        'link_route': linkRoute,
        'is_active': isActive,
        'sort_order': sortOrder,
        'audience': audience,
      };

  BannerSlideModel copyWith({
    String? title,
    String? subtitle,
    String? mediaUrl,
    String? mediaType,
    String? linkRoute,
    bool? isActive,
    int? sortOrder,
    String? audience,
  }) =>
      BannerSlideModel(
        id: id,
        title: title ?? this.title,
        subtitle: subtitle ?? this.subtitle,
        mediaUrl: mediaUrl ?? this.mediaUrl,
        mediaType: mediaType ?? this.mediaType,
        linkRoute: linkRoute ?? this.linkRoute,
        isActive: isActive ?? this.isActive,
        sortOrder: sortOrder ?? this.sortOrder,
        audience: audience ?? this.audience,
      );
}
