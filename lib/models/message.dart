import 'package:communal/models/profile.dart';

class Message {
  String id;
  final DateTime created_at;
  Profile sender;
  Profile receiver;
  final String content;
  bool is_read;

  Message({
    required this.id,
    required this.created_at,
    required this.sender,
    required this.receiver,
    required this.content,
    required this.is_read,
  });

  Message.fromMap(Map<String, dynamic> map)
      : receiver = Profile.fromMap(map['receiver_profile']),
        sender = Profile.fromMap(map['sender_profile']),
        content = map['content'],
        created_at = DateTime.parse(map['created_at']),
        is_read = map['is_read'],
        id = map['id'];

  @override
  String toString() {
    return {
      'id': id,
      'created_at': created_at.toIso8601String(),
      'sender': sender.id,
      'receiver': receiver.id,
      'is_read': is_read,
    }.toString();
  }
  // Message.empty()
  //     : id = '',
  //       created_at = DateTime.now(),
  //       sender = Profile.,
  //       receiver = Profile.,
  //       content = '',
  //       is_read = false;
}
