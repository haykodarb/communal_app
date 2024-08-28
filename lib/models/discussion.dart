import 'package:communal/models/community.dart';
import 'package:communal/models/profile.dart';

class DiscussionTopic {
  final String id;
  final DateTime created_at;
  final Profile creator;
  final Community community;
  final String name;
  final DiscussionMessage last_message;

  DiscussionTopic({
    required this.id,
    required this.created_at,
    required this.creator,
    required this.community,
    required this.name,
    required this.last_message,
  });

  DiscussionTopic.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        created_at = DateTime.parse(
          map['created_at'],
        ),
        creator = Profile.fromMap(
          map['profiles'],
        ),
        community = Community.fromMap(map['communities']),
        name = map['name'],
        last_message = DiscussionMessage.fromMapWithoutTopic(map['last_message']);
}

class DiscussionMessage {
  final String id;
  final DateTime created_at;
  final Profile sender;
  final String content;

  DiscussionMessage({
    required this.id,
    required this.created_at,
    required this.sender,
    required this.content,
  });

  DiscussionMessage.fromMap(Map<String, dynamic> map)
      : sender = Profile.fromMap(map['profiles']),
        content = map['content'],
        created_at = DateTime.parse(map['created_at']),
        id = map['id'];

  DiscussionMessage.fromMapWithoutTopic(Map<String, dynamic> map)
      : sender = Profile.fromMap(map['profiles']),
        content = map['content'],
        created_at = DateTime.parse(map['created_at']),
        id = map['id'];

  @override
  String toString() {
    return {
      'id': id,
      'created_at': created_at.toIso8601String(),
      'sender': sender.id,
      'content': content,
    }.toString();
  }
}
