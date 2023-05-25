class Community {
  String? uuid;
  String name;
  String description;

  Community({
    required this.name,
    required this.description,
    this.uuid,
  });
}
