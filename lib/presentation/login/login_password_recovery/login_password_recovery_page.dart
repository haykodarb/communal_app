import 'package:communal/presentation/common/common_button.dart';
import 'package:communal/presentation/common/common_text_field.dart';
import 'package:communal/presentation/login/login_password_recovery/login_password_recovery_controller.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginPasswordRecoveryPage extends StatelessWidget {
  const LoginPasswordRecoveryPage({super.key});

  Widget _recoveryForm(
      LoginPasswordRecoveryController controller, BuildContext context) {
    return Form(
      key: controller.formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CommonTextField(
            validator: controller.emailValidator,
            submitCallback: (_) => controller.onSubmit(context),
            callback: controller.onEmailChange,
            label: 'Email'.tr,
          ),
          const Divider(height: 30),
          CommonButton(
            onPressed: controller.onSubmit,
            loading: controller.loading,
            child: Text('Send'.tr),
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
          backgroundColor: Theme.of(context).colorScheme.surface,
          resizeToAvoidBottomInset: false,
          body: Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: 600,
              child: SingleChildScrollView(
                child: Padding(
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
                              alignment: Alignment.topLeft,
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'Recover password'.tr,
                                textAlign: TextAlign.left,
                                style: const TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 30),
                      _recoveryForm(controller, context),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
