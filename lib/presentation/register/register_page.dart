import 'package:communal/presentation/common/common_loading_body.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:communal/presentation/common/common_text_field.dart';
import 'package:communal/presentation/register/register_controller.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({Key? key}) : super(key: key);

  Widget _registerForm(RegisterController controller) {
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
            validator: controller.usernameValidator,
            callback: controller.onUsernameChange,
            label: 'Username',
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
            child: Obx(
              () => CommonLoadingBody(
                isLoading: controller.loading.value,
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
          ),
          ElevatedButton(
            onPressed: controller.onSubmitButton,
            child: const Text('Register'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: RegisterController(),
      builder: (RegisterController controller) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          resizeToAvoidBottomInset: false,
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(
                top: 75,
                right: 50,
                left: 50,
              ),
              child: _registerForm(controller),
            ),
          ),
        );
      },
    );
  }
}
