class Profile {
  final String username;
  final String id;
  final bool? is_admin;

  Profile({
    required this.username,
    required this.id,
    this.is_admin,
  });
}
