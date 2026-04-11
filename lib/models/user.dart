enum UserRole { pastor, admin, dept_head, media_team, treasurer, member, child }

class AppUser {
  final String id;
  final String email;
  final String name;
  final String phone;
  final UserRole role;
  final String department;
  final DateTime? joinDate;
  final String status;

  const AppUser({
    required this.id,
    required this.email,
    required this.name,
    required this.phone,
    required this.role,
    required this.department,
    this.joinDate,
    required this.status,
  });

  factory AppUser.fromSupabase(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      email: json['email'] as String? ?? '',
      name: json['name'] as String,
      phone: json['phone'] as String? ?? '',
      role: _parseRole(json['role'] as String?),
      department: json['department'] as String? ?? '',
      joinDate: json['join_date'] != null
          ? DateTime.parse(json['join_date'] as String)
          : null,
      status: json['status'] as String? ?? 'active',
    );
  }

  Map<String, dynamic> toSupabase() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'role': role.name,
      'department': department,
      'join_date': joinDate?.toIso8601String(),
      'status': status,
    };
  }

  static UserRole _parseRole(String? roleString) {
    switch (roleString?.toLowerCase()) {
      case 'pastor':
        return UserRole.pastor;
      case 'admin':
        return UserRole.admin;
      case 'department_head':
      case 'dept_head':
        return UserRole.dept_head;
      case 'media_team':
        return UserRole.media_team;
      case 'treasurer':
        return UserRole.treasurer;
      case 'child':
        return UserRole.child;
      default:
        return UserRole.member;
    }
  }

  bool get isPastor => role == UserRole.pastor;
  bool get isAdmin => role == UserRole.admin || role == UserRole.pastor;
  bool get isDeptHead => role == UserRole.dept_head || isAdmin;
  bool get isMediaTeam => role == UserRole.media_team;
  bool get isTreasurer => role == UserRole.treasurer;
  bool get isMember => role == UserRole.member;
  bool get isChild => role == UserRole.child;
  bool get canManageContent => isAdmin || isMediaTeam;
  bool get canManageFinances => isAdmin || isTreasurer;

  bool get isChildrensDept =>
      department.toLowerCase().contains('children') ||
      department.toLowerCase().contains('child') ||
      department.toLowerCase().contains('teacher');

  bool get canManageChildrenContent =>
      isAdmin || (role == UserRole.dept_head && isChildrensDept);

  bool canEditDepartment(String departmentName) {
    return isAdmin; // Pastors and admins can edit any department
  }
}
