class Community {
  String id;
  String name;
  String? image_path;
  String owner;
  bool isCurrentUserAdmin;

  Community({
    required this.name,
    required this.id,
    required this.image_path,
    required this.owner,
    required this.isCurrentUserAdmin,
  });

  Community.empty()
      : id = '',
        name = '',
        image_path = '',
        owner = '',
        isCurrentUserAdmin = false;
}
