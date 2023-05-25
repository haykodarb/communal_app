import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:biblioteca/presentation/common/text_field.dart';
import 'package:biblioteca/presentation/login/login_controller.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  Widget _loginButton(LoginController controller) {
    return ElevatedButton(
      onPressed: controller.loginButtonCallback,
      child: const Text(
        'Login',
      ),
    );
  }

  Widget _loginForm(LoginController controller) {
    final BuildContext context = Get.context!;

    return Form(
      key: controller.formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CustomTextField(
            validator: controller.emailValidator,
            callback: controller.onEmailChange,
            label: 'Email',
          ),
          CustomTextField(
            validator: controller.passwordValidator,
            callback: controller.onPasswordChange,
            label: 'Password',
            isPassword: true,
          ),
          Obx(
            () => Visibility(
              visible: controller.loading.value,
              child: const SizedBox(
                height: 100,
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
          ),
          Obx(
            () => Visibility(
              visible: controller.errorMessage.value != '',
              child: SizedBox(
                height: 100,
                child: Center(
                  child: Text(
                    controller.errorMessage.value,
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.error,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),
          _loginButton(controller),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: LoginController(),
      builder: (LoginController controller) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          body: Padding(
            padding: const EdgeInsets.only(
              top: 75,
              right: 50,
              left: 50,
            ),
            child: _loginForm(controller),
          ),
        );
      },
    );
  }
}
