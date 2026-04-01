class Member {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String department;
  final DateTime joinDate;
  final String status;
  /// Additional ministries / departments this person leads or serves in.
  /// Stored as a comma-separated string in Supabase.
  final List<String> ministries;
  /// Whether this person is a head/leader of their primary department.
  final bool isDeptHead;
  /// Indicates an acting/temporary role.
  final bool isActing;

  const Member({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.department,
    required this.joinDate,
    required this.status,
    this.ministries = const [],
    this.isDeptHead = false,
    this.isActing = false,
  });

  factory Member.fromSupabase(Map<String, dynamic> json) {
    final rawMinistries = json['ministries'] as String? ?? '';
    final ministryList = rawMinistries.isEmpty
        ? <String>[]
        : rawMinistries.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();

    return Member(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      role: json['role'] as String? ?? 'Member',
      department: json['department'] as String? ?? '',
      joinDate: json['join_date'] != null
          ? DateTime.parse(json['join_date'] as String)
          : DateTime.now(),
      status: json['status'] as String? ?? 'Active',
      ministries: ministryList,
      isDeptHead: (json['is_dept_head'] as bool?) ?? false,
      isActing: (json['is_acting'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toSupabase() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'department': department,
      'join_date': joinDate.toIso8601String(),
      'status': status,
      'ministries': ministries.join(', '),
      'is_dept_head': isDeptHead,
      'is_acting': isActing,
    };
  }

  Member copyWith({
    String? name,
    String? email,
    String? phone,
    String? role,
    String? department,
    DateTime? joinDate,
    String? status,
    List<String>? ministries,
    bool? isDeptHead,
    bool? isActing,
  }) {
    return Member(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      department: department ?? this.department,
      joinDate: joinDate ?? this.joinDate,
      status: status ?? this.status,
      ministries: ministries ?? this.ministries,
      isDeptHead: isDeptHead ?? this.isDeptHead,
      isActing: isActing ?? this.isActing,
    );
  }
}
