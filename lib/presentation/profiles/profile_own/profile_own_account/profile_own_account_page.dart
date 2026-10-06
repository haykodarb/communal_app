import 'package:communal/presentation/common/common_button.dart';
import 'package:communal/presentation/common/common_text_field.dart';
import 'package:communal/presentation/profiles/profile_own/profile_own_account/profile_own_account_controller.dart';
import 'package:communal/responsive.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileOwnAccountPage extends StatelessWidget {
  const ProfileOwnAccountPage({super.key});

  Widget _title(String text, {Color? color}) {
    return Builder(
      builder: (context) => Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: color ?? Theme.of(context).colorScheme.secondary,
          ),
        ),
      ),
    );
  }

  Widget _muted(String text) {
    return Builder(
      builder: (context) => Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _message(RxnString message) {
    return Obx(
      () => Visibility(
        visible: message.value != null,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(
            message.value ?? '',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(Get.context!).colorScheme.primary,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: ProfileOwnAccountController(),
      builder: (ProfileOwnAccountController controller) {
        final Color error = Theme.of(context).colorScheme.error;

        return Scaffold(
          appBar: AppBar(
            title: Responsive.isMobile(context)
                ? Text('Account settings'.tr)
                : null,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Form(
                    key: controller.emailFormKey,
                    child: Column(
                      children: [
                        _title('Email'.tr),
                        const Divider(height: 10),
                        _muted(controller.user?.email ?? ''),
                        if ((controller.user?.newEmail ?? '').isNotEmpty)
                          _muted(
                            'Waiting for confirmation of {email}.'
                                .tr
                                .replaceFirst(
                                    '{email}', controller.user!.newEmail!),
                          ),
                        const Divider(height: 10),
                        CommonTextField(
                          label: 'New email'.tr,
                          callback: (value) => controller.newEmail = value,
                          validator: controller.emailValidator,
                          submitCallback: (_) =>
                              controller.changeEmail(context),
                        ),
                        const Divider(height: 10),
                        _message(controller.emailMessage),
                        CommonButton(
                          loading: controller.emailLoading,
                          onPressed: controller.changeEmail,
                          child: Text('Change email'.tr),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 40),
                  Form(
                    key: controller.passwordFormKey,
                    child: Column(
                      children: [
                        _title('Password'.tr),
                        const Divider(height: 10),
                        CommonPasswordField(
                          label: 'New password'.tr,
                          callback: (value) => controller.newPassword = value,
                          validator: controller.passwordValidator,
                        ),
                        const Divider(height: 5),
                        CommonPasswordField(
                          label: 'Repeat password'.tr,
                          callback: (value) =>
                              controller.repeatPassword = value,
                          validator: controller.repeatPasswordValidator,
                          submitCallback: (_) =>
                              controller.changePassword(context),
                        ),
                        const Divider(height: 10),
                        _message(controller.passwordMessage),
                        CommonButton(
                          loading: controller.passwordLoading,
                          onPressed: controller.changePassword,
                          child: Text('Change password'.tr),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 40),
                  _title('Delete account'.tr, color: error),
                  const Divider(height: 10),
                  _muted(
                    'This deletes your profile, books, loans, messages and friendships. It cannot be undone.'
                        .tr,
                  ),
                  const Divider(height: 10),
                  Obx(
                    () => Visibility(
                      visible: controller.errorMessage.value != null,
                      child: Text(
                        controller.errorMessage.value ?? '',
                        style: TextStyle(color: error, fontSize: 14),
                      ),
                    ),
                  ),
                  // Destructive: the outlined button in the error color.
                  Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme:
                          Theme.of(context).colorScheme.copyWith(primary: error),
                    ),
                    child: CommonButton(
                      type: CommonButtonType.outlined,
                      loading: controller.deleteLoading,
                      onPressed: controller.deleteAccount,
                      child: Text('Delete account'.tr),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
