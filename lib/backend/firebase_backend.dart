import 'package:communal/backend/users_backend.dart';
import 'package:communal/models/backend_response.dart';
import 'package:communal/routes.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:go_router/go_router.dart';

class FirebaseBackend {
  static void handleNotificationMessage(
    RemoteMessage message,
    GoRouter router,
  ) async {
    if (message.data['table'] != null) {
      switch (message.data['table']) {
        case 'messages':
          router.push('${RouteNames.messagesPage}/${message.data['id']}');
          break;
        case 'notifications':
          router.go(RouteNames.notificationsPage);
          break;
        default:
          break;
      }
    }
  }

  static Future<BackendResponse> firebaseInit(GoRouter router) async {
    try {
      await FirebaseMessaging.instance.requestPermission(provisional: true);

      final String? fcmToken = await FirebaseMessaging.instance.getToken();

      if (fcmToken != null) {
        UsersBackend.updateFCMToken(fcmToken);
      }

      // Get any messages which caused the application to open from
      // a terminated state.
      RemoteMessage? initialMessage =
          await FirebaseMessaging.instance.getInitialMessage();

      // If the message also contains a data property with a "type" of "chat",
      // navigate to a chat screen
      if (initialMessage != null) {
        handleNotificationMessage(initialMessage, router);
      }

      // Also handle any interaction when the app is in the background using a
      // Stream listener
      FirebaseMessaging.onMessageOpenedApp.listen(
        (message) => handleNotificationMessage(message, router),
      );

      return BackendResponse(success: true);
    } catch (e) {
      return BackendResponse(success: false);
    }
  }
}
