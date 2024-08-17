import 'package:communal/backend/users_backend.dart';

class Community {
  String id;
  String name;
  String? description;
  String? image_path;
  String owner;
  bool? isCurrentUserAdmin;

  Community({
    required this.name,
    required this.id,
    required this.image_path,
    required this.owner,
    this.isCurrentUserAdmin,
  });

  bool get isCurrentUserOwner {
    return UsersBackend.currentUserId == owner;
  }

  Community.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        name = map['name'],
        owner = map['owner'],
        description = map['description'],
        image_path = map['image_path'];

  Community.empty()
      : id = '',
        name = '',
        image_path = '',
        owner = '';
}
