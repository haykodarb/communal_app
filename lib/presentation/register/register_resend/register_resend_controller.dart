import 'package:communal/backend/register_backend.dart';
import 'package:communal/models/backend_response.dart';
import 'package:communal/presentation/common/common_alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RegisterResendController extends GetxController {
  final RxBool loading = false.obs;

  String email = '';

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  void onEmailChange(String value) {
    email = value;
  }

  Future<void> onSubmit(BuildContext context) async {
    final bool? validForm = formKey.currentState?.validate();

    if (validForm != null && validForm) {
      loading.value = true;

      final BackendResponse response = await RegisterBackend.resendEmail(email: email);

      if (context.mounted) {
        await CommonAlertDialog(title: response.payload).open(context);
      }

      loading.value = false;
    }
  }

  String? emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter something'.tr;
    }

    if (!value.isEmail) {
      return 'Input must be a valid email';
    }

    return null;
  }
}
