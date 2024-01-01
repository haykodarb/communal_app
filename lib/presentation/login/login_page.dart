import 'package:communal/presentation/common/common_loading_body.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:communal/presentation/common/common_text_field.dart';
import 'package:communal/presentation/login/login_controller.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  Widget _loginForm(LoginController controller) {
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
          CommonPasswordField(
            validator: controller.passwordValidator,
            callback: controller.onPasswordChange,
            label: 'Password',
          ),
          const Divider(),
          Container(
            alignment: Alignment.centerRight,
            height: 50,
            width: double.maxFinite,
            child: TextButton(
              child: Text(
                'Forgot password?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Theme.of(Get.context!).colorScheme.onBackground,
                ),
                textAlign: TextAlign.right,
              ),
              onPressed: () {},
            ),
          ),
          const Divider(),
          Obx(
            () => CommonLoadingBody(
              loading: controller.loading.value,
              size: 40,
              child: ElevatedButton(
                onPressed: controller.loginButtonCallback,
                child: const Text('Login'),
              ),
            ),
          ),
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
