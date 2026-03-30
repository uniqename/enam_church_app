class Ministry {
  final String id;
  final String name;
  final String description;
  final String leader;
  final String meetingDay;
  final String meetingTime;
  final String location;
  final String whatsappGroup;
  final List<String> members;

  const Ministry({
    required this.id,
    required this.name,
    required this.description,
    required this.leader,
    required this.meetingDay,
    required this.meetingTime,
    required this.location,
    this.whatsappGroup = '',
    this.members = const [],
  });

  factory Ministry.fromSupabase(Map<String, dynamic> json) {
    return Ministry(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      leader: json['leader'] as String? ?? '',
      meetingDay: json['meeting_day'] as String? ?? '',
      meetingTime: json['meeting_time'] as String? ?? '',
      location: json['location'] as String? ?? '',
      whatsappGroup: json['whatsapp_group'] as String? ?? '',
      members: (json['members'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toSupabase() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'leader': leader,
      'meeting_day': meetingDay,
      'meeting_time': meetingTime,
      'location': location,
      'whatsapp_group': whatsappGroup,
      'members': members,
    };
  }

  Ministry copyWith({
    String? name,
    String? description,
    String? leader,
    String? meetingDay,
    String? meetingTime,
    String? location,
    String? whatsappGroup,
    List<String>? members,
  }) =>
      Ministry(
        id: id,
        name: name ?? this.name,
        description: description ?? this.description,
        leader: leader ?? this.leader,
        meetingDay: meetingDay ?? this.meetingDay,
        meetingTime: meetingTime ?? this.meetingTime,
        location: location ?? this.location,
        whatsappGroup: whatsappGroup ?? this.whatsappGroup,
        members: members ?? this.members,
      );
}
