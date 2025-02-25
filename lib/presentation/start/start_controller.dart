import 'package:communal/backend/login_backend.dart';
import 'package:communal/backend/user_preferences.dart';
import 'package:communal/models/backend_response.dart';
import 'package:communal/presentation/common/common_alert_dialog.dart';
import 'package:communal/routes.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

class StartController extends GetxController {
  StartController({required this.context});
  final BuildContext context;

  final RxBool loading = false.obs;

  Future<void> changeThemeMode(BuildContext context) async {
    final ThemeMode newThemeMode = UserPreferences.isDarkMode(context) ? ThemeMode.light : ThemeMode.dark;

    Get.changeThemeMode(newThemeMode);

    UserPreferences.setSelectedThemeMode(newThemeMode);
  }

  void changeLanguage(Locale? value) {
    if (value == null) return;
    if (Get.locale == value) return;

    Get.updateLocale(value);
    UserPreferences.setSelectedLocale(value);
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      loading.value = true;

      final BackendResponse response = await LoginBackend.signInWithGoogle();

      if (!response.success && context.mounted) {
        CommonAlertDialog(title: response.error ?? '').open(context);
      }

      if (response.success && context.mounted) {
        context.go(RouteNames.communityListPage);
      }

      loading.value = false;
    } catch (e) {
      loading.value = false;
    }
  }
}
