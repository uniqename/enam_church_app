class GroupFinance {
  final String id;
  final String groupId;
  final String title;
  final String body;
  final double amount;
  final DateTime date;
  final String postedBy;
  final String category; // 'budget', 'expense', 'plan', 'report'

  const GroupFinance({
    required this.id,
    required this.groupId,
    required this.title,
    this.body = '',
    this.amount = 0,
    required this.date,
    this.postedBy = '',
    this.category = 'budget',
  });

  factory GroupFinance.fromJson(Map<String, dynamic> j) => GroupFinance(
    id: j['id'] as String,
    groupId: j['group_id'] as String? ?? '',
    title: j['title'] as String? ?? '',
    body: j['body'] as String? ?? '',
    amount: (j['amount'] as num?)?.toDouble() ?? 0,
    date: j['date'] != null ? DateTime.parse(j['date'] as String) : DateTime.now(),
    postedBy: j['posted_by'] as String? ?? '',
    category: j['category'] as String? ?? 'budget',
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'group_id': groupId, 'title': title, 'body': body,
    'amount': amount, 'date': date.toIso8601String(),
    'posted_by': postedBy, 'category': category,
  };
}
