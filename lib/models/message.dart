class Message {
  final String id;
  final String senderId;
  final String senderName;
  final String recipientId; // 'all' | userId | 'group:{name}' | 'leaders'
  final String recipientName; // display name for DMs
  final String subject;
  final String content;
  final DateTime date;
  final bool read;
  final String priority;
  final String messageType; // 'broadcast' | 'direct' | 'group' | 'leaders'

  const Message({
    required this.id,
    required this.senderId,
    this.senderName = '',
    required this.recipientId,
    this.recipientName = '',
    required this.subject,
    required this.content,
    required this.date,
    required this.read,
    required this.priority,
    this.messageType = 'broadcast',
  });

  bool get isBroadcast =>
      messageType == 'broadcast' || recipientId == 'all';
  bool get isDirect => messageType == 'direct';
  bool get isGroup => messageType == 'group';
  bool get isLeaders => messageType == 'leaders';

  String get groupName =>
      recipientId.startsWith('group:') ? recipientId.substring(6) : '';

  factory Message.fromSupabase(Map<String, dynamic> json) {
    final recipientId = json['recipient_id'] as String? ?? 'all';
    // Infer type from recipientId for backwards compat
    String inferredType;
    if (json['message_type'] != null) {
      inferredType = json['message_type'] as String;
    } else if (recipientId == 'all') {
      inferredType = 'broadcast';
    } else if (recipientId == 'leaders') {
      inferredType = 'leaders';
    } else if (recipientId.startsWith('group:')) {
      inferredType = 'group';
    } else {
      inferredType = 'direct';
    }

    return Message(
      id: json['id'] as String,
      senderId: json['sender_id'] as String,
      senderName: json['sender_name'] as String? ?? '',
      recipientId: recipientId,
      recipientName: json['recipient_name'] as String? ?? '',
      subject: json['subject'] as String? ?? '',
      content: json['content'] as String,
      date: DateTime.parse(json['date'] as String),
      read: json['read'] as bool? ?? false,
      priority: json['priority'] as String? ?? 'Normal',
      messageType: inferredType,
    );
  }

  Map<String, dynamic> toSupabase() => {
        'id': id,
        'sender_id': senderId,
        'sender_name': senderName,
        'recipient_id': recipientId,
        'recipient_name': recipientName,
        'subject': subject,
        'content': content,
        'date': date.toIso8601String(),
        'read': read,
        'priority': priority,
        'message_type': messageType,
      };

  Message copyWith({bool? read}) => Message(
        id: id,
        senderId: senderId,
        senderName: senderName,
        recipientId: recipientId,
        recipientName: recipientName,
        subject: subject,
        content: content,
        date: date,
        read: read ?? this.read,
        priority: priority,
        messageType: messageType,
      );
}
