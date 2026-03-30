class Finance {
  final String id;
  final String type;
  final double amount;
  final String memberName;
  final DateTime date;
  final String method;
  final String status;
  final String department; // which department this transaction belongs to

  const Finance({
    required this.id,
    required this.type,
    required this.amount,
    required this.memberName,
    required this.date,
    required this.method,
    required this.status,
    this.department = '',
  });

  factory Finance.fromSupabase(Map<String, dynamic> json) {
    return Finance(
      id: json['id'] as String,
      type: json['type'] as String,
      amount: (json['amount'] as num).toDouble(),
      memberName: json['member_name'] as String? ?? '',
      date: DateTime.parse(json['date'] as String),
      method: json['method'] as String? ?? 'Cash',
      status: json['status'] as String? ?? 'Completed',
      department: json['department'] as String? ?? '',
    );
  }

  Map<String, dynamic> toSupabase() {
    return {
      'id': id,
      'type': type,
      'amount': amount,
      'member_name': memberName,
      'date': date.toIso8601String().split('T')[0],
      'method': method,
      'status': status,
      'department': department,
    };
  }

  Finance copyWith({
    String? type,
    double? amount,
    String? memberName,
    DateTime? date,
    String? method,
    String? status,
    String? department,
  }) {
    return Finance(
      id: id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      memberName: memberName ?? this.memberName,
      date: date ?? this.date,
      method: method ?? this.method,
      status: status ?? this.status,
      department: department ?? this.department,
    );
  }
}
