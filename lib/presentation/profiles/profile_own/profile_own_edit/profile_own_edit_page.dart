import 'package:atlas_icons/atlas_icons.dart';
import 'package:communal/backend/login_backend.dart';
import 'package:communal/backend/users_backend.dart';
import 'package:communal/presentation/common/common_async_text_field.dart';
import 'package:communal/presentation/common/common_boolean_selector.dart';
import 'package:communal/presentation/common/common_button.dart';
import 'package:communal/presentation/common/common_circular_avatar.dart';
import 'package:communal/presentation/common/common_confirmation_dialog.dart';
import 'package:communal/presentation/common/common_loading_body.dart';
import 'package:communal/presentation/common/common_text_field.dart';
import 'package:communal/presentation/profiles/profile_own/profile_own_edit/profile_own_edit_controller.dart';
import 'package:communal/responsive.dart';
import 'package:communal/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class ProfileOwnEditPage extends StatelessWidget {
  const ProfileOwnEditPage({super.key});

  Widget _showEmailToggleSwitch(ProfileOwnEditController controller) {
    return Builder(
      builder: (context) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Make email public?'.tr,
              style: const TextStyle(fontSize: 14),
            ),
            const Divider(),
            Obx(
              () => CommonBooleanSelector(
                callback: controller.onShowEmailChanged,
                value: controller.newShowEmail.value,
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
        init: ProfileOwnEditController(),
        builder: (ProfileOwnEditController controller) {
          return Scaffold(
            appBar: AppBar(
              title:
                  Responsive.isMobile(context) ? Text('Edit profile'.tr) : null,
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Form(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  key: controller.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 200,
                        width: 200,
                        child: Stack(
                          children: [
                            Align(
                              alignment: Alignment.center,
                              child: Obx(
                                () {
                                  return CommonCircularAvatar(
                                    profile: controller.inheritedProfile.value,
                                    radius: 100,
                                    image:
                                        controller.selectedBytes.value != null
                                            ? Image.memory(
                                                controller.selectedBytes.value!,
                                                fit: BoxFit.cover,
                                              )
                                            : null,
                                  );
                                },
                              ),
                            ),
                            Align(
                              alignment: Alignment.topRight,
                              child: Obx(
                                () => Visibility(
                                  visible:
                                      controller.selectedBytes.value != null,
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.close,
                                      color:
                                          Theme.of(context).colorScheme.error,
                                    ),
                                    iconSize: 40,
                                    onPressed: () {
                                      controller.selectedBytes.value = null;
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 10),
                      Builder(builder: (context) {
                        if (!Responsive.isMobile(context)) {
                          return InkWell(
                            onTap: () => controller.takePicture(
                              ImageSource.gallery,
                              context,
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              padding: const EdgeInsets.all(13),
                              child: Icon(
                                Atlas.image_gallery,
                                color: Theme.of(context).colorScheme.onPrimary,
                                size: 24,
                              ),
                            ),
                          );
                        }

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: () => controller.takePicture(
                                ImageSource.camera,
                                context,
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                padding: const EdgeInsets.all(13),
                                child: Icon(
                                  Atlas.camera,
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                  size: 24,
                                ),
                              ),
                            ),
                            const VerticalDivider(width: 25),
                            InkWell(
                              onTap: () => controller.takePicture(
                                ImageSource.gallery,
                                context,
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                padding: const EdgeInsets.all(13),
                                child: Icon(
                                  Atlas.image_gallery,
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                  size: 24,
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                      const Divider(height: 30),
                      Form(
                        child: Column(
                          children: [
                            Obx(
                              () {
                                return CommonAsyncTextField(
                                  callback: controller.onUsernameChanged,
                                  label: 'Username'.tr,
                                  duration: const Duration(milliseconds: 500),
                                  asyncValidator:
                                      controller.asyncUsernameValidator,
                                  syncValidator: controller.usernameValidator,
                                  initialValue: controller
                                      .inheritedProfile.value.username,
                                );
                              },
                            ),
                            const Divider(height: 5),
                            Obx(
                              () {
                                return CommonTextField(
                                  callback: controller.onBioChanged,
                                  label: 'Bio (Optional)'.tr,
                                  validator: controller.bioValidator,
                                  initialValue:
                                      controller.inheritedProfile.value.bio,
                                  maxLength: 1000,
                                  maxLines: 10,
                                  minLines: 3,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 20),
                      _showEmailToggleSwitch(controller),
                      const Divider(height: 20),
                      CommonButton(
                        onPressed: controller.onSubmit,
                        loading: controller.loading,
                        child: Text('Save'.tr),
                      ),
                      const Divider(height: 50),
                      TextButton(
                        onPressed: () async {
                          final bool res = await const CommonConfirmationDialog(
                            title:
                                'Are you sure you want to delete your account? This is immediate and cannot be undone.',
                          ).open(context);

                          if (res) {
                            controller.loading.value = true;
                            final bool result = await UsersBackend.deleteUser();

                            if (result) {
                              await LoginBackend.logout();
                              if (context.mounted) {
                                context.go(RouteNames.startPage);
                              }
                            }
                            controller.loading.value = false;
                          }
                        },
                        child: Text(
                          'Delete account'.tr,
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }
}
