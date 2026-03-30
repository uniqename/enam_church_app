class OrgGroup {
  final String id;
  final String name;
  final String description;
  final List<String> leaders;
  final List<String> members;
  final String meetingDay;
  final String meetingTime;
  final String location;
  final String whatsappGroup;

  const OrgGroup({
    required this.id,
    required this.name,
    this.description = '',
    required this.leaders,
    this.members = const [],
    this.meetingDay = '',
    this.meetingTime = '',
    this.location = '',
    this.whatsappGroup = '',
  });

  /// Convenience getter — returns the primary leader name
  String get leader => leaders.isNotEmpty ? leaders.first : '';

  factory OrgGroup.fromJson(Map<String, dynamic> json) {
    List<String> leadersList;
    final rawLeaders = json['leaders'];
    if (rawLeaders is List) {
      leadersList = rawLeaders.map((e) => e.toString()).toList();
    } else {
      final single = json['leader'] as String? ??
          json['head'] as String? ?? '';
      leadersList = single.isNotEmpty ? [single] : [];
    }

    return OrgGroup(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      leaders: leadersList,
      members: (json['members'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      meetingDay: json['meeting_day'] as String? ?? '',
      meetingTime: json['meeting_time'] as String? ?? '',
      location: json['location'] as String? ?? '',
      whatsappGroup: json['whatsapp_group'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'leaders': leaders,
        'members': members,
        'meeting_day': meetingDay,
        'meeting_time': meetingTime,
        'location': location,
        'whatsapp_group': whatsappGroup,
      };

  OrgGroup copyWith({
    String? name,
    String? description,
    List<String>? leaders,
    List<String>? members,
    String? meetingDay,
    String? meetingTime,
    String? location,
    String? whatsappGroup,
  }) =>
      OrgGroup(
        id: id,
        name: name ?? this.name,
        description: description ?? this.description,
        leaders: leaders ?? this.leaders,
        members: members ?? this.members,
        meetingDay: meetingDay ?? this.meetingDay,
        meetingTime: meetingTime ?? this.meetingTime,
        location: location ?? this.location,
        whatsappGroup: whatsappGroup ?? this.whatsappGroup,
      );
}
