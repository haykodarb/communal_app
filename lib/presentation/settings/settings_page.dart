import 'package:atlas_icons/atlas_icons.dart';
import 'package:communal/backend/user_preferences.dart';
import 'package:communal/presentation/common/common_button.dart';
import 'package:communal/presentation/common/common_drawer/common_drawer_widget.dart';
import 'package:communal/presentation/common/common_switch.dart';
import 'package:communal/presentation/common/common_text_field.dart';
import 'package:communal/presentation/settings/settings_controller.dart';
import 'package:communal/responsive.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Settings: language and theme, change password, delete account. A drawer
/// page, so the title is only in the mobile app bar.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

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
    return Builder(
      builder: (context) => Obx(
        () => Visibility(
          visible: message.value != null,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              message.value ?? '',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _switchRow(String label, Widget toggle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        const Expanded(child: VerticalDivider()),
        toggle,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: SettingsController(),
      builder: (SettingsController controller) {
        final Color error = Theme.of(context).colorScheme.error;

        return Scaffold(
          appBar: Responsive.isMobile(context)
              ? AppBar(title: Text('Settings'.tr))
              : null,
          drawer:
              Responsive.isMobile(context) ? const CommonDrawerWidget() : null,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _title('Preferences'.tr),
                  const Divider(height: 10),
                  _switchRow(
                    'Language'.tr,
                    CommonSwitch(
                      callback: controller.toggleLanguage,
                      value: Get.locale == SettingsController.locales[0],
                      labels: const ['EN', 'ES'],
                    ),
                  ),
                  const Divider(height: 10),
                  _switchRow(
                    'Theme'.tr,
                    CommonSwitch(
                      value: !UserPreferences.isDarkMode(context),
                      callback: () => controller.toggleThemeMode(context),
                      icons: const [Atlas.sunny_bold, Atlas.moon_bold],
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
                        SizedBox(
                          width: double.maxFinite,
                          child: CommonButton(
                            loading: controller.passwordLoading,
                            onPressed: controller.changePassword,
                            child: Text('Change password'.tr),
                          ),
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
                  SizedBox(
                    width: double.maxFinite,
                    child: CommonButton(
                      type: CommonButtonType.outlined,
                      loading: controller.deleteLoading,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: error,
                        side: BorderSide(color: error, width: 2),
                      ),
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
