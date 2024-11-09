import 'package:communal/presentation/common/common_async_text_field.dart';
import 'package:communal/presentation/common/common_loading_body.dart';
import 'package:communal/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:communal/presentation/common/common_text_field.dart';
import 'package:communal/presentation/register/register_controller.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  Widget _registerForm(RegisterController controller) {
    return Builder(builder: (context) {
      return Form(
        key: controller.formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CommonTextField(
              validator: controller.emailValidator,
              callback: controller.onEmailChange,
              label: 'email'.tr,
            ),
            const Divider(height: 5),
            CommonAsyncTextField(
              callback: controller.onUsernameChange,
              label: 'username'.tr,
              duration: const Duration(milliseconds: 500),
              asyncValidator: controller.asyncUsernameValidator,
              syncValidator: controller.usernameValidator,
            ),
            const Divider(height: 5),
            CommonPasswordField(
              validator: controller.passwordValidator,
              callback: controller.onPasswordChange,
              label: 'password'.tr,
            ),
            const Divider(height: 5),
            Container(
              alignment: Alignment.centerRight,
              height: 20,
              width: double.maxFinite,
              child: TextButton(
                child: Text(
                  'Resend confirmation?',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  textAlign: TextAlign.right,
                ),
                onPressed: () {
                  context.go(RouteNames.registerResendPage);
                },
              ),
            ),
            const Divider(height: 30),
            Obx(
              () => CommonLoadingBody(
                loading: controller.loading.value,
                size: 40,
                child: ElevatedButton(
                  onPressed: controller.onSubmitButton,
                  child: Text('register'.tr),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: RegisterController(),
      builder: (RegisterController controller) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          resizeToAvoidBottomInset: false,
          body: Align(
            alignment: Alignment.topCenter,
            child: Obx(
              () {
                if (controller.submitted.value) {
                  return SafeArea(
                    child: Container(
                      width: 600,
                      padding: const EdgeInsets.all(60),
                      child: Center(
                        child: Column(
                          children: [
                            const Text(
                              'A confirmation link\nhas been sent to:',
                              style: TextStyle(fontSize: 18),
                              textAlign: TextAlign.center,
                            ),
                            const Divider(height: 20),
                            Text(
                              controller.form.value.email,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                color: Theme.of(context).colorScheme.tertiary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Divider(height: 20),
                            const Text(
                              'Please validate your\nemail and then login.',
                              style: TextStyle(
                                fontSize: 14,
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
                              child: Text(
                                'resend-confirmation'.tr,
                                style: const TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                              onPressed: () {
                                context.go(RouteNames.registerResendPage);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return SingleChildScrollView(
                  child: Container(
                    width: 600,
                    padding: const EdgeInsets.only(
                      top: 100,
                      right: 40,
                      left: 40,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 50),
                          child: Text(
                            'create-account'.tr,
                            textAlign: TextAlign.left,
                            style: GoogleFonts.lora(
                              fontSize: 40,
                              height: 1.2,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const Divider(height: 40),
                        _registerForm(controller),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
