import 'package:get/get.dart';
import 'package:biblioteca/backend/register_backend.dart';
import 'package:biblioteca/models/backend_response.dart';
import 'package:biblioteca/models/register_form.dart';
import 'package:biblioteca/routes.dart';
import 'package:flutter/material.dart';
import 'package:string_validator/string_validator.dart';

class RegisterController extends GetxController {
  final Rx<RegisterForm> form = RegisterForm(
    username: '',
    password: '',
    email: '',
  ).obs;

  final RxBool loading = false.obs;

  final RxString errorMessage = ''.obs;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  String? emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter something.';
    }

    if (!value.isEmail) {
      return 'Input must be a valid email.';
    }

    return null;
  }

  String? usernameValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter something.';
    }

    if (value.length < 6) {
      return 'Username must be at least 6 characters long';
    }

    if (!isAscii(value)) {
      return 'Username should only include ASCII characters';
    }

    return null;
  }

  String? passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter something.';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }

    if (!isAscii(value)) {
      return 'Password should only include ASCII characters';
    }

    return null;
  }

  void onUsernameChange(String value) {
    form.update((val) {
      val!.username = value;
    });
  }

  void onEmailChange(String value) {
    form.update((val) {
      val!.email = value;
    });
  }

  void onPasswordChange(String value) {
    form.update((val) {
      val!.password = value;
    });
  }

  Future<void> onSubmitButton() async {
    if (formKey.currentState!.validate()) {
      loading.value = true;
      errorMessage.value = '';

      final BackendResponse response = await RegisterBackend.register(
        form: form.value,
      );

      loading.value = false;

      if (response.success) {
        Get.offAllNamed(RouteNames.startPage);
      } else {
        errorMessage.value = response.payload;
      }
    }
  }
}
