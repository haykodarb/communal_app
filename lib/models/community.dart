class Community {
  String? id;
  String name;
  String description;
  bool? isCurrentUserAdmin;

  Community({
    required this.name,
    required this.description,
    this.id,
    this.isCurrentUserAdmin,
  });
}
