import 'package:communal/models/backend_response.dart';
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
  String resource_id;
  String resource_name;
  Profile? sender;
  Profile receiver;
  bool seen;

  CustomNotification({
    required this.id,
    required this.type,
    required this.resource_id,
    required this.resource_name,
    required this.receiver,
    required this.seen,
  });

  CustomNotification.empty()
      : id = 0,
        resource_id = '',
        resource_name = '',
        receiver = Profile.empty(),
        type = NotificationType.empty(),
        seen = false;

  CustomNotification.fromMap(Map<String, dynamic> map)
      : receiver = Profile.fromMap(map['receiver']),
        sender = map['sender'] == null ? null : Profile.fromMap(map['sender']),
        id = map['id'],
        seen = map['seen'],
        type = NotificationType.fromMap(map['type']),
        resource_id = map['resource_id'],
        resource_name = map['resource_name'];
}

class NotificationsBackend {
  static Future<BackendResponse> getUnreadNotificationsCount() async {
    try {
      final SupabaseClient client = Supabase.instance.client;

      final String userId = client.auth.currentUser!.id;

      final int result = await client.from('notifications').count().eq('receiver', userId);

      return BackendResponse(success: true, payload: result);
    } catch (e) {
      return BackendResponse(success: false, payload: 'Error, please try again.');
    }
  }

  static Future<BackendResponse> getNotifications() async {
    try {
      final SupabaseClient client = Supabase.instance.client;

      final String userId = client.auth.currentUser!.id;

      final List<Map<String, dynamic>> result = await client
          .from('notifications')
          .select('*, type(*), receiver:profiles!receiver(*), sender:profiles!sender(*)')
          .eq('receiver', userId);

      final List<CustomNotification> notifications = result.map((e) => CustomNotification.fromMap(e)).toList();

      return BackendResponse(success: true, payload: notifications);
    } catch (e) {
      print(e);
      return BackendResponse(success: false, payload: 'Error, please try again.');
    }
  }
}
