import 'package:communal/presentation/common/common_loading_body.dart';
import 'package:communal/presentation/common/common_text_field.dart';
import 'package:communal/presentation/register/register_resend/register_resend_controller.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class RegisterResendPage extends StatelessWidget {
  const RegisterResendPage({super.key});

  Widget _resendForm(RegisterResendController controller) {
    return Form(
      key: controller.formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CommonTextField(
            validator: controller.emailValidator,
            submitCallback: (value) => controller.onSubmit(),
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
      init: RegisterResendController(),
      builder: (RegisterResendController controller) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          resizeToAvoidBottomInset: false,
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(
                top: 75,
                right: 50,
                left: 50,
              ),
              child: _resendForm(controller),
            ),
          ),
        );
      },
    );
  }
}
