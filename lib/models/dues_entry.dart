class DuesEntry {
  final String id;
  final String groupId;
  final String memberName;
  final double amount;
  final DateTime date;
  final String period; // 'monthly', 'quarterly', 'annual', 'one-time'
  final String note;
  final String postedBy;

  const DuesEntry({
    required this.id,
    required this.groupId,
    required this.memberName,
    required this.amount,
    required this.date,
    this.period = 'monthly',
    this.note = '',
    this.postedBy = '',
  });

  factory DuesEntry.fromJson(Map<String, dynamic> j) => DuesEntry(
    id: j['id'] as String,
    groupId: j['group_id'] as String? ?? '',
    memberName: j['member_name'] as String? ?? '',
    amount: (j['amount'] as num?)?.toDouble() ?? 0,
    date: j['date'] != null ? DateTime.parse(j['date'] as String) : DateTime.now(),
    period: j['period'] as String? ?? 'monthly',
    note: j['note'] as String? ?? '',
    postedBy: j['posted_by'] as String? ?? '',
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'group_id': groupId, 'member_name': memberName,
    'amount': amount, 'date': date.toIso8601String(),
    'period': period, 'note': note, 'posted_by': postedBy,
  };
}
