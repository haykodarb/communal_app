import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:biblioteca/presentation/common/text_field.dart';
import 'package:biblioteca/presentation/register/register_controller.dart';

class RegisterPage extends StatelessWidget {
  RegisterPage({Key? key}) : super(key: key);

  final RegisterController _registerController = RegisterController();

  Widget _registerForm() {
    final BuildContext context = Get.context!;

    return ConstrainedBox(
      constraints: BoxConstraints.loose(
        const Size.fromHeight(600),
      ),
      child: Form(
        key: _registerController.formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CustomTextField(
              validator: _registerController.emailValidator,
              callback: _registerController.onEmailChange,
              label: 'Email',
            ),
            CustomTextField(
              validator: _registerController.usernameValidator,
              callback: _registerController.onUsernameChange,
              label: 'Username',
            ),
            CustomTextField(
              validator: _registerController.passwordValidator,
              callback: _registerController.onPasswordChange,
              label: 'Password',
              isPassword: true,
            ),
            SizedBox(
              height: 70,
              child: Obx(
                () => Text(
                  _registerController.errorMessage.value,
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: _registerController.onSubmitButton,
              child: const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: _registerController,
      builder: (RegisterController controller) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          body: Padding(
            padding: const EdgeInsets.only(
              top: 75,
              right: 50,
              left: 50,
            ),
            child: _registerForm(),
          ),
        );
      },
    );
  }
}
