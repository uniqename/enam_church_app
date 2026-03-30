class OrgGroup {
  final String id;
  final String name;
  final String description;
  final List<String> leaders;
  final List<String> members;
  final List<String> pendingMembers;
  final String meetingDay;
  final String meetingTime;
  final String location;
  final String whatsappGroup;
  final String googleMeetLink;
  final double dues;
  final String duesPeriod; // monthly / quarterly / annual
  final String bylaws;

  const OrgGroup({
    required this.id,
    required this.name,
    this.description = '',
    required this.leaders,
    this.members = const [],
    this.pendingMembers = const [],
    this.meetingDay = '',
    this.meetingTime = '',
    this.location = '',
    this.whatsappGroup = '',
    this.googleMeetLink = '',
    this.dues = 0,
    this.duesPeriod = 'monthly',
    this.bylaws = '',
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
      pendingMembers: (json['pending_members'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      googleMeetLink: json['google_meet_link'] as String? ?? '',
      dues: (json['dues'] as num?)?.toDouble() ?? 0,
      duesPeriod: json['dues_period'] as String? ?? 'monthly',
      bylaws: json['bylaws'] as String? ?? '',
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
      'pending_members': pendingMembers,
      'google_meet_link': googleMeetLink,
      'dues': dues,
      'dues_period': duesPeriod,
      'bylaws': bylaws,
      };

  OrgGroup copyWith({
    String? name,
    String? description,
    List<String>? leaders,
    List<String>? members,
    List<String>? pendingMembers,
    String? meetingDay,
    String? meetingTime,
    String? location,
    String? whatsappGroup,
    String? googleMeetLink,
    double? dues,
    String? duesPeriod,
    String? bylaws,
  }) =>
      OrgGroup(
        id: id,
        name: name ?? this.name,
        description: description ?? this.description,
        leaders: leaders ?? this.leaders,
        members: members ?? this.members,
        pendingMembers: pendingMembers ?? this.pendingMembers,
        meetingDay: meetingDay ?? this.meetingDay,
        meetingTime: meetingTime ?? this.meetingTime,
        location: location ?? this.location,
        whatsappGroup: whatsappGroup ?? this.whatsappGroup,
        googleMeetLink: googleMeetLink ?? this.googleMeetLink,
        dues: dues ?? this.dues,
        duesPeriod: duesPeriod ?? this.duesPeriod,
        bylaws: bylaws ?? this.bylaws,
      );
}
