import 'package:communal/backend/users_backend.dart';
import 'package:get/get.dart';
import 'package:communal/backend/register_backend.dart';
import 'package:communal/models/backend_response.dart';
import 'package:communal/models/register_form.dart';
import 'package:flutter/material.dart';
import 'package:string_validator/string_validator.dart';

class RegisterController extends GetxController {
  final Rx<RegisterForm> form = RegisterForm(
    username: '',
    password: '',
    email: '',
  ).obs;

  final RxBool loading = false.obs;

  final RxBool submitted = false.obs;

  final RxString errorMessage = ''.obs;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  String? emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'enter-something'.tr;
    }

    if (!GetUtils.isEmail(value)) {
      return 'Input must be a valid email.';
    }

    return null;
  }

  Future<String?> asyncUsernameValidator(String? value) async {
    if (value == null) {
      return 'Input can\'t be empty';
    }

    final bool available = await UsersBackend.validateUsername(value);

    if (!available) {
      return 'Username is already taken.';
    }

    return null;
  }

  String? usernameValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'enter-something'.tr;
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
      return 'enter-something'.tr;
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
        submitted.value = true;
      } else {
        errorMessage.value = response.payload;
      }
    }
  }
}
