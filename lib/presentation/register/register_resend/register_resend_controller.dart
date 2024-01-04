import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RegisterResendController extends GetxController {
  final RxBool loading = false.obs;

  final RxString email = ''.obs;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  void onEmailChange(String value) {
    email.value = value;
  }

  Future<void> onSubmit() async {
    final bool? validForm = formKey.currentState?.validate();

    if (validForm != null && validForm) {
      // final BackendResponse response = await RegisterBackend.resendEmail(email: email.value);
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
