import 'package:communal/presentation/common/common_loading_body.dart';
import 'package:communal/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:communal/presentation/common/common_text_field.dart';
import 'package:communal/presentation/login/login_controller.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  Widget _loginForm(LoginController controller) {
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
                'forgot-password'.tr,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Theme.of(Get.context!).colorScheme.secondary,
                ),
                textAlign: TextAlign.right,
              ),
              onPressed: () {
                Get.toNamed(RouteNames.loginRecoveryPage);
              },
            ),
          ),
          Obx(
            () => Text(
              controller.errorMessage.value,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(Get.context!).colorScheme.error,
              ),
            ),
          ),
          const Divider(height: 30),
          Obx(
            () => CommonLoadingBody(
              loading: controller.loading.value,
              size: 40,
              child: ElevatedButton(
                onPressed: controller.loginButtonCallback,
                child: Text(
                  'login'.tr,
                ),
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
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: SingleChildScrollView(
            child: Padding(
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
                      'sign-in'.tr,
                      textAlign: TextAlign.left,
                      style: GoogleFonts.lora(
                        fontSize: 40,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Divider(height: 40),
                  _loginForm(controller),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
