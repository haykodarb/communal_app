import 'package:communal/models/book.dart';
import 'package:communal/models/friendship.dart';
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
    'friendships': {
      'created': null,
      'accepted': 'You became friends with ',
    },
    'books': {
      'available': null,
    },
  };

  static const _notificationEnds = {
    'loans': {
      'accepted': ' has been accepted by ',
      'rejected': ' has been rejected by ',
      'created': ' by ',
      'returned': ' has been marked as returned by ',
    },
    'friendships': {
      'created': '\nsent you a friend request.',
      'accepted': null,
    },
    'books': {
      'available': ' is available again.',
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
  Friendship? friendship;

  /// books/available: a waitlisted book is back.
  Book? book;
  DateTime updated_at;
  Profile? sender;
  Profile receiver;
  bool seen;

  RxBool loading = false.obs;

  CustomNotification({
    required this.id,
    required this.type,
    required this.receiver,
    required this.seen,
    required this.updated_at,
  });

  CustomNotification.empty()
      : id = 0,
        receiver = Profile.empty(),
        type = NotificationType.empty(),
	updated_at = DateTime.now(),
        seen = false;

  CustomNotification.fromMap(Map<String, dynamic> map)
      : receiver = Profile.fromMap(map['receiver']),
        sender = map['sender'] == null ? null : Profile.fromMap(map['sender']),
        id = map['id'],
        updated_at = DateTime.parse(map['updated_at']),
        seen = map['seen'],
        type = NotificationType.fromMap(map['type']),
        loan = map['loans'] != null ? Loan.fromMap(map['loans']) : null,
        friendship = map['friendships'] != null
            ? Friendship.fromMap(map['friendships'])
            : null,
        book = map['books'] != null ? Book.fromMap(map['books']) : null;
}
