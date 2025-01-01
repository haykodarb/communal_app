import 'package:communal/backend/users_backend.dart';
import 'package:get/get.dart';

class Community {
  String id;
  String name;
  String? description;
  String? image_path;
  String owner;
  bool? isCurrentUserAdmin;
  int user_count;
  RxBool pinned = false.obs;

  Community({
    required this.name,
    required this.id,
    required this.image_path,
    required this.owner,
    required this.user_count,
    this.isCurrentUserAdmin,
    this.description,
  });

  bool get isCurrentUserOwner {
    return UsersBackend.currentUserId == owner;
  }

  Community.fromMembershipMap(Map<String, dynamic> map)
      : name = map['communities']['name'],
        id = map['communities']['id'],
        description = map['communities']['description'],
        image_path = map['communities']['image_path'],
        owner = map['communities']['owner'],
        user_count = map['communities']['user_count'],
        isCurrentUserAdmin = map['is_admin'];

  Community.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        name = map['name'],
        user_count = map['user_count'],
        owner = map['owner'],
        description = map['description'],
        image_path = map['image_path'];

  Community.copy(Community source)
      : id = source.id,
        user_count = source.user_count,
        name = source.name,
        owner = source.owner,
        image_path = source.image_path,
        description = source.description,
        pinned = source.pinned,
        isCurrentUserAdmin = source.isCurrentUserAdmin;

  Community.empty()
      : id = '',
        name = '',
        user_count = 0,
        image_path = '',
        owner = '';
}
