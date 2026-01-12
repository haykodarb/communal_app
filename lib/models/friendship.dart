import 'package:communal/models/profile.dart';
import 'package:get/get.dart';

class Friendship {
  final String id;
  final DateTime created_at;
  final Profile requester;
  final Profile responder;
  final bool? accepted;
  final DateTime? accepted_at;

  final RxBool loading = false.obs;

  Friendship({
    required this.id,
    required this.created_at,
    required this.requester,
    required this.responder,
    required this.accepted,
    required this.accepted_at,
  });

  Friendship.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        created_at = DateTime.parse(map['created_at']).toLocal(),
        accepted_at = DateTime.tryParse(map['accepted_at'] ?? '')?.toLocal(),
        requester = Profile.fromMap(map['requester_profile']),
        responder = Profile.fromMap(map['responder_profile']),
        accepted = map['accepted'];

  bool get isRequesterCurrentUser => requester.isCurrentUser;
  bool get isResponderCurrentUser => responder.isCurrentUser;

  Profile get otherUser => isRequesterCurrentUser ? responder : requester;

  bool get isPending => accepted == null;
  bool get isAccepted => accepted == true;
  bool get isRejected => accepted == false;
}
