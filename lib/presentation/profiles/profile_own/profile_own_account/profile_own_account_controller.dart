import 'package:communal/backend/login_backend.dart';
import 'package:communal/backend/users_backend.dart';
import 'package:communal/models/backend_response.dart';
import 'package:communal/presentation/common/common_confirmation_dialog.dart';
import 'package:communal/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:string_validator/string_validator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Account settings: change email, change password, delete account.
class ProfileOwnAccountController extends GetxController {
  final GlobalKey<FormState> emailFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> passwordFormKey = GlobalKey<FormState>();

  String newEmail = '';
  String newPassword = '';
  String repeatPassword = '';

  final RxBool emailLoading = false.obs;
  final RxBool passwordLoading = false.obs;
  final RxBool deleteLoading = false.obs;

  final RxnString emailMessage = RxnString();
  final RxnString passwordMessage = RxnString();
  final RxnString errorMessage = RxnString();

  User? get user => Supabase.instance.client.auth.currentUser;

  String? emailValidator(String? value) {
    if (value == null || !isEmail(value.trim())) {
      return 'Please enter a valid email'.tr;
    }
    return null;
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

  Future<void> changeEmail(BuildContext context) async {
    emailMessage.value = null;
    if (!emailFormKey.currentState!.validate()) return;

    emailLoading.value = true;
    final BackendResponse response =
        await LoginBackend.updateUserEmail(newEmail.trim());
    emailLoading.value = false;

    emailMessage.value = response.success
        ? 'Check your inbox: we sent a confirmation link to {email}.'
            .tr
            .replaceFirst('{email}', newEmail.trim())
        : response.payload?.toString();
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
