import 'package:communal/models/profile.dart';

class Tool {
  String id;
  DateTime created_at;
  Profile owner;
  String name;
  String image_path;
  String description;
  bool available;

  Tool({
    required this.id,
    required this.created_at,
    required this.name,
    required this.owner,
    required this.image_path,
    required this.available,
    required this.description,
  });

  Tool.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        created_at = DateTime.parse(map['created_at']),
        name = map['name'],
        owner = Profile.fromMap(map['profiles']),
        available = map['available'],
        description = map['description'],
        image_path = map['image_path'];

  Tool.empty()
      : id = '',
        created_at = DateTime.now(),
        name = '',
        image_path = '',
        description = '',
        available = false,
        owner = Profile.empty();
}
