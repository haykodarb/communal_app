import 'package:communal/backend/login_backend.dart';
import 'package:communal/models/backend_response.dart';
import 'package:communal/presentation/common/common_alert_dialog.dart';
import 'package:communal/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

class LoginPasswordRecoveryController extends GetxController {
  final RxBool loading = false.obs;

  final RxString email = ''.obs;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  void onEmailChange(String value) {
    email.value = value;
  }

  Future<void> onSubmit(BuildContext context) async {
    final bool? validForm = formKey.currentState?.validate();

    if (validForm != null && validForm) {
      loading.value = true;
      final BackendResponse response = await LoginBackend.sendRecoveryEmail(email.value);

      if (context.mounted) {
        await CommonAlertDialog(title: response.payload).open(context);

        if (context.mounted) {
          context.go(RouteNames.startPage);
        }
      }

      loading.value = false;
    }
  }

  String? emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter something.';
    }

    if (!value.isEmail) {
      return 'Input must be a valid email.';
    }

    return null;
  }
}
