import 'package:communal/backend/user_preferences.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:communal/routes.dart';

class StartController extends GetxController {
  void loginButtonCallback() {
    Get.toNamed(RouteNames.loginPage);
  }

  Future<void> changeThemeMode() async {
    final ThemeMode newThemeMode = Get.isDarkMode ? ThemeMode.light : ThemeMode.dark;

    Get.changeThemeMode(newThemeMode);

    UserPreferences.setSelectedThemeMode(newThemeMode);
  }

  void changeLanguage(Locale? value) {
    if (value == null) return;
    if (Get.locale == value) return;

    Get.updateLocale(value);
    UserPreferences.setSelectedLocale(value);
  }

  void registerButtonCallback() {
    Get.toNamed(RouteNames.registerPage);
  }
}
