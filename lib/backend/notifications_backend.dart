import 'package:communal/backend/users_backend.dart';
import 'package:communal/models/backend_response.dart';
import 'package:communal/models/custom_notification.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
            '*, type(*), receiver:profiles!receiver(*), sender:profiles!sender(*), loans!left(*, books!left(*, profiles(*)), loanee_profile:profiles!loanee(*), owner_profile:profiles!owner(*)), memberships!left(*, communities(*), profiles(*))',
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

  static Future<BackendResponse> getNotifications(
      int pageKey, int count) async {
    try {
      final SupabaseClient client = Supabase.instance.client;

      final String userId = client.auth.currentUser!.id;

      final List<Map<String, dynamic>> result = await client
          .from('notifications')
          .select(
            '*, type(*), receiver:profiles!receiver(*), sender:profiles!sender(*), loans!left(*, books!left(*, profiles(*)),  loanee_profile:profiles!loanee(*), owner_profile:profiles!owner(*)), memberships!left(*, communities(*, profiles(*)), profiles(*))',
          )
          .eq('receiver', userId)
          .order('created_at', ascending: false)
          .range(pageKey, pageKey + (count - 1));

      final List<CustomNotification> notifications = result.map(
        (e) {
          return CustomNotification.fromMap(e);
        },
      ).toList();

      return BackendResponse(success: true, payload: notifications);
    } catch (e, _) {
      return BackendResponse(
        success: false,
        payload: e,
      );
    }
  }
}
