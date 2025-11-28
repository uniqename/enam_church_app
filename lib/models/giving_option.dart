class GivingOption {
  final int id;
  final String type;
  final String description;
  final List<int> suggested;
  final String frequency;

  GivingOption({
    required this.id,
    required this.type,
    required this.description,
    required this.suggested,
    required this.frequency,
  });
}
