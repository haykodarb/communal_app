import 'package:communal/backend/login_backend.dart';
import 'package:communal/backend/user_preferences.dart';
import 'package:communal/backend/users_backend.dart';
import 'package:communal/models/backend_response.dart';
import 'package:communal/presentation/common/common_confirmation_dialog.dart';
import 'package:communal/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:string_validator/string_validator.dart';

/// Settings: language, theme, change password, delete account.
class SettingsController extends GetxController {
  static const List<Locale> locales = [Locale('en', 'US'), Locale('es', 'ES')];

  final GlobalKey<FormState> passwordFormKey = GlobalKey<FormState>();

  String newPassword = '';
  String repeatPassword = '';

  final RxBool passwordLoading = false.obs;
  final RxBool deleteLoading = false.obs;

  final RxnString passwordMessage = RxnString();
  final RxnString errorMessage = RxnString();

  void toggleLanguage() {
    final Locale next = Get.locale == locales[0] ? locales[1] : locales[0];
    UserPreferences.setSelectedLocale(next);
    Get.updateLocale(next);
  }

  /// An explicit choice: saved, so it no longer follows the system.
  void toggleThemeMode(BuildContext context) {
    final ThemeMode next =
        UserPreferences.isDarkMode(context) ? ThemeMode.light : ThemeMode.dark;
    Get.changeThemeMode(next);
    UserPreferences.setSelectedThemeMode(next);
  }

  String? passwordValidator(String? value) {
    if (value == null || value.length < 6) {
      return 'Password must be at least 6 characters long'.tr;
    }
    if (!isAscii(value)) {
      return 'Password should only include ASCII characters'.tr;
    }
    return null;
  }

  String? repeatPasswordValidator(String? value) {
    if (value != newPassword) return 'Passwords do not match'.tr;
    return null;
  }

  Future<void> changePassword(BuildContext context) async {
    passwordMessage.value = null;
    if (!passwordFormKey.currentState!.validate()) return;

    passwordLoading.value = true;
    final BackendResponse response =
        await LoginBackend.updateUserPassword(newPassword);
    passwordLoading.value = false;

    passwordMessage.value = response.success
        ? 'Password updated.'.tr
        : 'Error in updating password, please try again.'.tr;
  }

  Future<void> deleteAccount(BuildContext context) async {
    final bool confirmed = await CommonConfirmationDialog(
      title:
          'Are you sure you want to delete your account? This is immediate and cannot be undone.'
              .tr,
    ).open(context);
    if (!confirmed) return;

    deleteLoading.value = true;
    errorMessage.value = null;
    final bool deleted = await UsersBackend.deleteUser();

    if (!deleted) {
      deleteLoading.value = false;
      errorMessage.value =
          'Could not delete your account, please try again.'.tr;
      return;
    }

    await LoginBackend.logout();
    Get.deleteAll();
    if (context.mounted) context.go(RouteNames.startPage);
  }
}
