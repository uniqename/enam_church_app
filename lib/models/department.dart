class Department {
  final String id;
  final String name;
  final List<String> heads; // supports multiple heads/leaders
  final List<String> members;
  final String whatsappGroup;
  final String slackChannel;

  const Department({
    required this.id,
    required this.name,
    required this.heads,
    required this.members,
    required this.whatsappGroup,
    required this.slackChannel,
  });

  /// Convenience getter for backwards compatibility — returns the primary head
  String get head => heads.isNotEmpty ? heads.first : '';

  factory Department.fromSupabase(Map<String, dynamic> json) {
    // Support both old `head` (String) and new `heads` (List) from Supabase
    List<String> headsList;
    final rawHeads = json['heads'];
    if (rawHeads is List) {
      headsList = rawHeads.map((e) => e.toString()).toList();
    } else {
      final singleHead = json['head'] as String? ?? '';
      headsList = singleHead.isNotEmpty ? [singleHead] : [];
    }

    return Department(
      id: json['id'] as String,
      name: json['name'] as String,
      heads: headsList,
      members: (json['members'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      whatsappGroup: json['whatsapp_group'] as String? ?? '',
      slackChannel: json['slack_channel'] as String? ?? '',
    );
  }

  Map<String, dynamic> toSupabase() {
    return {
      'id': id,
      'name': name,
      'heads': heads,
      'members': members,
      'whatsapp_group': whatsappGroup,
      'slack_channel': slackChannel,
    };
  }

  Department copyWith({
    String? name,
    List<String>? heads,
    List<String>? members,
    String? whatsappGroup,
    String? slackChannel,
  }) =>
      Department(
        id: id,
        name: name ?? this.name,
        heads: heads ?? this.heads,
        members: members ?? this.members,
        whatsappGroup: whatsappGroup ?? this.whatsappGroup,
        slackChannel: slackChannel ?? this.slackChannel,
      );
}
