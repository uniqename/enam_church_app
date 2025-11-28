class User {
  final int id;
  final String username;
  final String password;
  final String role;
  final String name;
  final String email;
  final String? phone;
  final String? department;
  final String? parent;
  final int? age;

  User({
    required this.id,
    required this.username,
    required this.password,
    required this.role,
    required this.name,
    required this.email,
    this.phone,
    this.department,
    this.parent,
    this.age,
  });
}
