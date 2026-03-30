class Membership {
  final String id;
  final String userId;
  final String type;
  final String status;
  final DateTime startDate;
  final DateTime? expiryDate;
  final String benefits;

  const Membership({
    required this.id,
    required this.userId,
    required this.type,
    required this.status,
    required this.startDate,
    this.expiryDate,
    required this.benefits,
  });

  factory Membership.fromSupabase(Map<String, dynamic> json) {
    return Membership(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      type: json['type'] as String? ?? 'Regular',
      status: json['status'] as String? ?? 'Active',
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'] as String)
          : DateTime.now(),
      expiryDate: json['expiry_date'] != null
          ? DateTime.parse(json['expiry_date'] as String)
          : null,
      benefits: json['benefits'] as String? ?? '',
    );
  }

  Map<String, dynamic> toSupabase() {
    return {
      'id': id,
      'user_id': userId,
      'type': type,
      'status': status,
      'start_date': startDate.toIso8601String().split('T')[0],
      'expiry_date': expiryDate?.toIso8601String().split('T')[0],
      'benefits': benefits,
    };
  }
}
