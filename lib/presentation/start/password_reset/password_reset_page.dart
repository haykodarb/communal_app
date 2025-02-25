import 'package:communal/backend/login_backend.dart';
import 'package:communal/models/backend_response.dart';
import 'package:communal/presentation/common/common_alert_dialog.dart';
import 'package:communal/presentation/common/common_loading_body.dart';
import 'package:communal/presentation/common/common_text_field.dart';
import 'package:communal/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:string_validator/string_validator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PasswordResetController extends GetxController {
  RxBool loading = false.obs;
  String password = '';

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  void onPasswordChange(String value) {
    password = value;
  }

  Future<void> onSubmit(BuildContext context) async {
    final bool validForm = formKey.currentState?.validate() ?? false;

    if (validForm) {
      loading.value = true;
      final BackendResponse response = await LoginBackend.updateUserPassword(password);

      if (context.mounted) {
        await CommonAlertDialog(title: response.payload).open(context);

        await Supabase.instance.client.auth.signOut();

        if (context.mounted) {
          context.go(RouteNames.startPage + RouteNames.loginPage);
        }
      }

      loading.value = false;
    }
  }

  String? passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter something.';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }

    if (!value.isAscii) {
      return 'Password should only include ASCII characters';
    }

    return null;
  }
}

class PasswordResetPage extends StatelessWidget {
  const PasswordResetPage({super.key});

  Widget _recoveryForm(PasswordResetController controller, BuildContext context) {
    return Form(
      key: controller.formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CommonPasswordField(
            validator: controller.passwordValidator,
            submitCallback: (_) => controller.onSubmit(context),
            callback: controller.onPasswordChange,
            label: 'password'.tr,
          ),
          const Divider(height: 30),
          Obx(
            () => CommonLoadingBody(
              loading: controller.loading.value,
              size: 40,
              child: ElevatedButton(
                onPressed: () => controller.onSubmit(context),
                child: Text('send'.tr),
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
      init: PasswordResetController(),
      initState: (state) async {
        Uri? uri = GoRouter.of(context).state?.uri;
        if (uri != null) {
          try {
            await Supabase.instance.client.auth.getSessionFromUrl(uri);
          } catch (e) {
            if (context.mounted) {
              await const CommonAlertDialog(title: 'Wrong link.\nPlease re-request a password reset.').open(context);
            }
          }
        } else {
          await const CommonAlertDialog(title: 'Wrong link. Please re-request a password reset.').open(context);
        }
      },
      builder: (PasswordResetController controller) {
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
                          const Expanded(
                            child: FittedBox(
                              alignment: Alignment.topLeft,
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'Reset password',
                                textAlign: TextAlign.left,
                                style: TextStyle(
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
