import 'package:communal/backend/users_backend.dart';
import 'package:communal/models/backend_response.dart';
import 'package:communal/models/loan.dart';
import 'package:communal/models/membership.dart';
import 'package:communal/models/profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
}

class CustomNotification {
  int id;
  NotificationType type;
  Loan? loan;
  Membership? membership;
  Profile? sender;
  Profile receiver;
  bool seen;

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

class NotificationsBackend {
  static Future<BackendResponse> getUnreadNotificationsCount() async {
    try {
      final SupabaseClient client = Supabase.instance.client;

      final String userId = client.auth.currentUser!.id;

      final int result = await client
          .from('notifications')
          .count()
          .eq('receiver', userId)
          .eq('seen', false);

      return BackendResponse(success: true, payload: result);
    } catch (e) {
      return BackendResponse(
          success: false, payload: 'Error, please try again.');
    }
  }

  static Future<BackendResponse> getNotificationById(int id) async {
    try {
      final SupabaseClient client = Supabase.instance.client;

      final Map<String, dynamic> result = await client
          .from('notifications')
          .select(
            '*, type(*), receiver:profiles!receiver(*), sender:profiles!sender(*), loans!left(*, books!left(*, profiles(*)), communities(*), loanee_profile:profiles!loanee(*), owner_profile:profiles!owner(*)), memberships!left(*, communities(*), profiles(*))',
          )
          .eq('id', id)
          .single();

      if (result.isEmpty) {
        return BackendResponse(
          success: false,
          payload: 'Could not get notification.',
        );
      }

      return BackendResponse(
        success: true,
        payload: CustomNotification.fromMap(result),
      );
    } catch (e) {
      return BackendResponse(
        success: false,
        payload: 'Error, please try again.',
      );
    }
  }

  static Future<void> setNotificationsRead() async {
    final SupabaseClient client = Supabase.instance.client;

    await client
        .from('notifications')
        .update({'seen': true})
        .eq('receiver', UsersBackend.currentUserId)
        .eq('seen', false);
  }

  static Future<BackendResponse> getNotifications() async {
    try {
      final SupabaseClient client = Supabase.instance.client;

      final String userId = client.auth.currentUser!.id;

      final List<Map<String, dynamic>> result = await client
          .from('notifications')
          .select(
            '*, type(*), receiver:profiles!receiver(*), sender:profiles!sender(*), loans!left(*, books!left(*, profiles(*)), communities(*), loanee_profile:profiles!loanee(*), owner_profile:profiles!owner(*)), memberships!left(*, communities(*), profiles(*))',
          )
          .eq('receiver', userId)
          .order('created_at', ascending: false);

      final List<CustomNotification> notifications = result
          .map(
            (e) => CustomNotification.fromMap(e),
          )
          .toList();

      return BackendResponse(success: true, payload: notifications);
    } catch (e) {
      rethrow;
      return BackendResponse(
        success: false,
        payload: e,
      );
    }
  }
}
