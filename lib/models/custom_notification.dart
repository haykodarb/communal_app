import 'package:communal/models/loan.dart';
import 'package:communal/models/membership.dart';
import 'package:communal/models/profile.dart';
import 'package:get/get.dart';

 class NotificationType {
  int id;
  String table;
  String event;

  NotificationType({
    required this.id,
    required this.table,
    required this.event,
  });

  NotificationType.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        table = map['table'],
        event = map['event'];

  NotificationType.empty()
      : id = 0,
        table = '',
        event = '';

  static const _notificationStarts = {
    'loans': {
      'accepted': 'Your request for ',
      'rejected': 'Your request for ',
      'created': 'A request has been submitted for ',
      'returned': 'Your loan for ',
    },
    'memberships': {
      'created': 'You have been invited to join the community ',
      'accepted': 'You have joined the community ',
    },
  };

  static const _notificationEnds = {
    'loans': {
      'accepted': ' has been accepted by ',
      'rejected': ' has been rejected by ',
      'created': ' by ',
      'returned': ' has been marked as returned by ',
    },
    'memberships': {
      'created': null,
      'accepted': null,
    },
  };

  String get notificationStart => (_notificationStarts[table]?[event] ?? '').tr;
  String? get notificationEnd => _notificationEnds[table]?[event]?.tr;
}
class CustomNotification {
  int id;
  NotificationType type;
  Loan? loan;
  Membership? membership;
  Profile? sender;
  Profile receiver;
  bool seen;

  RxBool loading = false.obs;

  CustomNotification({
    required this.id,
    required this.type,
    required this.receiver,
    required this.seen,
  });

  CustomNotification.empty()
      : id = 0,
        receiver = Profile.empty(),
        type = NotificationType.empty(),
        seen = false;

  CustomNotification.fromMap(Map<String, dynamic> map)
      : receiver = Profile.fromMap(map['receiver']),
        sender = map['sender'] == null ? null : Profile.fromMap(map['sender']),
        id = map['id'],
        seen = map['seen'],
        type = NotificationType.fromMap(map['type']),
        loan = map['loans'] != null ? Loan.fromMap(map['loans']) : null,
        membership = map['memberships'] != null
            ? Membership.fromMap(map['memberships'])
            : null;
}
