import 'package:communal/presentation/common/common_async_text_field.dart';
import 'package:communal/presentation/common/common_button.dart';
import 'package:communal/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:communal/presentation/common/common_text_field.dart';
import 'package:communal/presentation/register/register_controller.dart';
import 'package:go_router/go_router.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  Widget _registerForm(RegisterController controller) {
    return Builder(builder: (context) {
      return Form(
        key: controller.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CommonTextField(
              validator: controller.emailValidator,
              callback: controller.onEmailChange,
              submitCallback: (value) => controller.onSubmitButton(context),
              label: 'Email'.tr,
            ),
            const Divider(height: 5),
            CommonAsyncTextField(
              callback: controller.onUsernameChange,
              label: 'Username'.tr,
              duration: const Duration(milliseconds: 500),
              asyncValidator: controller.asyncUsernameValidator,
              syncValidator: controller.usernameValidator,
              submitCallback: (value) => controller.onSubmitButton(context),
            ),
            const Divider(height: 5),
            CommonPasswordField(
              validator: controller.passwordValidator,
              callback: controller.onPasswordChange,
              submitCallback: (value) => controller.onSubmitButton(context),
              label: 'Password'.tr,
            ),
            const Divider(height: 5),
            Container(
              alignment: Alignment.centerRight,
              height: 20,
              width: double.maxFinite,
              child: TextButton(
                child: Text(
                  'Resend confirmation'.tr,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  textAlign: TextAlign.right,
                ),
                onPressed: () {
                  context.push(
                    RouteNames.startPage +
                        RouteNames.registerPage +
                        RouteNames.registerResendPage,
                  );
                },
              ),
            ),
            const Divider(height: 30),
            CommonButton(
              onPressed: controller.onSubmitButton,
              loading: controller.loading,
              child: Text('Register'.tr),
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
                            CommonButton(
                              type: CommonButtonType.outlined,
                              onPressed: (BuildContext context) {
                                context.go(
                                  RouteNames.startPage + RouteNames.loginPage,
                                );
                              },
                              child: const Text('Login'),
                            ),
                            const Divider(height: 20),
                            CommonButton(
                              type: CommonButtonType.text,
                              child: Text(
                                'Resend confirmation'.tr,
                                style: const TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                              onPressed: (BuildContext context) {
                                context.push(
                                  RouteNames.startPage +
                                      RouteNames.registerPage +
                                      RouteNames.registerResendPage,
                                );
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
                      children: [
                        Row(
                          children: [
                            IconButton(
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                context.pop();
                              },
                              icon: const Icon(Icons.chevron_left_rounded),
                              iconSize: 36,
                            ),
                            const VerticalDivider(width: 20),
                            Expanded(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Create account'.tr,
                                  textAlign: TextAlign.left,
                                  style: const TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                          ],
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
