class Message {
  final int id;
  final String sender;
  final String recipient;
  final String subject;
  final String content;
  final String date;
  final bool read;
  final String priority;

  Message({
    required this.id,
    required this.sender,
    required this.recipient,
    required this.subject,
    required this.content,
    required this.date,
    required this.read,
    required this.priority,
  });
}
