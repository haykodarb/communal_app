import 'dart:async';
import 'package:communal/backend/messages_backend.dart';
import 'package:communal/backend/notifications_backend.dart';
import 'package:communal/backend/realtime_backend.dart';
import 'package:communal/backend/user_preferences.dart';
import 'package:communal/backend/users_backend.dart';
import 'package:communal/models/backend_response.dart';
import 'package:communal/models/profile.dart';
import 'package:communal/models/realtime_message.dart';
import 'package:communal/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';

const List<String> rootRoutes = [
  RouteNames.myBooks,
  RouteNames.searchPage,
  RouteNames.profileOwnPage,
  RouteNames.notificationsPage,
  RouteNames.communityListPage,
  RouteNames.messagesPage,
  RouteNames.loansPage,
];

class CommonDrawerController extends GetxController {
  CommonDrawerController({required this.initialRoute});

  final String initialRoute;
  final RxInt messageNotifications = 0.obs;
  final RxInt globalNotifications = 0.obs;
  final RxString versionNumber = ''.obs;
  final RxString currentRoute = ''.obs;
  final Rx<Profile> currentUserProfile = Profile.empty().obs;

  Timer? debounceTimer;

  StreamSubscription? realtimeSubscription;

  void goToRoute(String routeName, BuildContext context) {
    currentRoute.value = routeName;
    context.go(routeName);
  }

  @override
  Future<void> onInit() async {
    super.onInit();

    currentRoute.value = '/${initialRoute.split('/')[1]}';

    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    RealtimeBackend.subscribeToDatabaseChanges();

    versionNumber.value = 'Version: ${packageInfo.version}+${packageInfo.buildNumber}';

    final BackendResponse userResponse = await UsersBackend.getUserProfile(
      UsersBackend.currentUserId,
    );

    if (userResponse.success) {
      currentUserProfile.value = userResponse.payload;
    }

    final BackendResponse notificationResponse = await NotificationsBackend.getUnreadNotificationsCount();

    if (notificationResponse.success) {
      globalNotifications.value = notificationResponse.payload;
    }

    getUnreadChats();

    realtimeSubscription ??= RealtimeBackend.streamController.stream.listen(realtimeChangeHandler);
  }

  @override
  Future<void> onClose() async {
    await realtimeSubscription?.cancel();

    debounceTimer?.cancel();

    super.onClose();
  }

  Future<void> realtimeChangeHandler(RealtimeMessage realtime) async {
    switch (realtime.table) {
      case 'messages':
        if (realtime.eventType == PostgresChangeEvent.insert || realtime.eventType == PostgresChangeEvent.update) {
          if (realtime.new_row['receiver'] == UsersBackend.currentUserId) {
            debounceTimer?.cancel();

            debounceTimer = Timer(
              const Duration(milliseconds: 500),
              () async {
                await getUnreadChats();
              },
            );
          }
        }
        break;

      case 'notifications':
        if (realtime.eventType != PostgresChangeEvent.delete) {
          if (realtime.new_row['receiver'] != UsersBackend.currentUserId) return;
        }

        final BackendResponse notificationResponse = await NotificationsBackend.getUnreadNotificationsCount();

        if (notificationResponse.success) {
          globalNotifications.value = notificationResponse.payload;
        }

        break;

      default:
        break;
    }
  }

  Future<void> getUnreadChats() async {
    final BackendResponse<int> response = await MessagesBackend.getUnreadChatCount();

    if (response.success) {
      messageNotifications.value = response.payload ?? 0;
    }
  }

  Future<void> changeThemeMode(BuildContext context) async {
    final ThemeMode newThemeMode = UserPreferences.isDarkMode(context) ? ThemeMode.light : ThemeMode.dark;

    Get.changeThemeMode(newThemeMode);

    UserPreferences.setSelectedThemeMode(newThemeMode);
  }
}
