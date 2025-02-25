import 'package:communal/presentation/common/common_loading_body.dart';
import 'package:communal/presentation/common/common_text_field.dart';
import 'package:communal/presentation/register/register_resend/register_resend_controller.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RegisterResendPage extends StatelessWidget {
  const RegisterResendPage({super.key});

  Widget _recoveryForm(RegisterResendController controller, BuildContext context) {
    return Form(
      key: controller.formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CommonTextField(
            validator: controller.emailValidator,
            submitCallback: (_) => controller.onSubmit(context),
            callback: controller.onEmailChange,
            label: 'Email',
          ),
          const Divider(height: 30),
          Obx(
            () => CommonLoadingBody(
              loading: controller.loading.value,
              size: 40,
              child: ElevatedButton(
                onPressed: () => controller.onSubmit(context),
                child: Text('Send'.tr),
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
                                'Resend confirmation'.tr,
                                textAlign: TextAlign.left,
                                style: const TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 40),
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
