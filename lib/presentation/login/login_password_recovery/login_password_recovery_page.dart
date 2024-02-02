import 'package:communal/presentation/common/common_loading_body.dart';
import 'package:communal/presentation/common/common_text_field.dart';
import 'package:communal/presentation/login/login_password_recovery/login_password_recovery_controller.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class LoginPasswordRecoveryPage extends StatelessWidget {
  const LoginPasswordRecoveryPage({super.key});

  Widget _recoveryForm(LoginPasswordRecoveryController controller) {
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
          const Divider(),
          Obx(
            () => CommonLoadingBody(
              loading: controller.loading.value,
              size: 40,
              child: ElevatedButton(
                onPressed: controller.onSubmit,
                child: const Text('Resend'),
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
      init: LoginPasswordRecoveryController(),
      builder: (LoginPasswordRecoveryController controller) {
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
              child: _recoveryForm(controller),
            ),
          ),
        );
      },
    );
  }
}
