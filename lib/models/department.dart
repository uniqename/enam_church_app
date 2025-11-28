class Department {
  final int id;
  final String name;
  final String head;
  final List<String> members;
  final String whatsappGroup;
  final String slackChannel;

  Department({
    required this.id,
    required this.name,
    required this.head,
    required this.members,
    required this.whatsappGroup,
    required this.slackChannel,
  });
}
