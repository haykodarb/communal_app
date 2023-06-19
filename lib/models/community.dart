import 'package:supabase_flutter/supabase_flutter.dart';

class Community {
  String id;
  String name;
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
    final String userId = Supabase.instance.client.auth.currentUser!.id;

    return userId == owner;
  }

  Community.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        name = map['name'],
        owner = map['owner'];

  Community.empty()
      : id = '',
        name = '',
        image_path = '',
        owner = '';
}
