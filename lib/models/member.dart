class Member {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String department;
  final DateTime joinDate;
  final String status;

  const Member({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.department,
    required this.joinDate,
    required this.status,
  });

  // Serialization for Supabase
  factory Member.fromSupabase(Map<String, dynamic> json) {
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
    };
  }

  // CopyWith for immutability
  Member copyWith({
    String? name,
    String? email,
    String? phone,
    String? role,
    String? department,
    DateTime? joinDate,
    String? status,
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
    );
  }
}
