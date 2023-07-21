import 'package:communal/presentation/common/common_loading_body.dart';
import 'package:communal/routes.dart';
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
                loading: controller.loading.value,
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
          body: Obx(
            () {
              if (controller.submitted.value) {
                return SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(60),
                    child: Center(
                      child: Column(
                        children: [
                          const Text(
                            'A confirmation link\nhas been sent to:',
                            style: TextStyle(fontSize: 20),
                            textAlign: TextAlign.center,
                          ),
                          const Divider(height: 20),
                          Text(
                            controller.form.value.email,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              color: Theme.of(context).colorScheme.tertiary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Divider(height: 20),
                          const Text(
                            'Please validate your\nemail and then login.',
                            style: TextStyle(
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const Divider(height: 100),
                          OutlinedButton(
                            onPressed: () {
                              Get.offNamed(RouteNames.loginPage);
                            },
                            child: const Text('Login'),
                          ),
                          const Divider(height: 20),
                          TextButton(
                            child: const Text(
                              'Resend email',
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 75,
                    right: 50,
                    left: 50,
                  ),
                  child: _registerForm(controller),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
