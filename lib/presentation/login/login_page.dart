import 'package:communal/presentation/common/common_loading_body.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:communal/presentation/common/common_text_field.dart';
import 'package:communal/presentation/login/login_controller.dart';

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
          CommonTextField(
            validator: controller.emailValidator,
            callback: controller.onEmailChange,
            label: 'Email',
          ),
          const Divider(color: Colors.transparent),
          CommonTextField(
            validator: controller.passwordValidator,
            callback: controller.onPasswordChange,
            label: 'Password',
            isPassword: true,
          ),
          const Divider(color: Colors.transparent),
          SizedBox(
            height: 70,
            child: CommonLoadingBody(
              loading: controller.loading,
              size: 40,
              child: Obx(
                () => Text(
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
