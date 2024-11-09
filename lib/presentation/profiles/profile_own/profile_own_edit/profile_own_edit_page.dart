import 'dart:io';
import 'package:atlas_icons/atlas_icons.dart';
import 'package:communal/presentation/common/common_async_text_field.dart';
import 'package:communal/presentation/common/common_boolean_selector.dart';
import 'package:communal/presentation/common/common_circular_avatar.dart';
import 'package:communal/presentation/common/common_responsive_page.dart';
import 'package:communal/presentation/common/common_text_field.dart';
import 'package:communal/presentation/profiles/profile_own/profile_own_edit/profile_own_edit_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ProfileOwnEditPage extends StatelessWidget {
  const ProfileOwnEditPage({super.key});

  Widget _showEmailToggleSwitch(ProfileOwnEditController controller) {
    return Builder(
      builder: (context) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Make email public?',
              style: TextStyle(fontSize: 14),
            ),
            const Divider(),
            Obx(
              () => CommonBooleanSelector(
                callback: controller.onShowEmailChanged,
                value: controller.profileForm.value.show_email,
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
          return CommonResponsivePage(
            child: Scaffold(
              appBar: AppBar(
                title: const Text('Edit profile'),
                actions: [
                  Obx(
                    () => controller.loading.value
                        ? SizedBox(
                            width: 30,
                            height: 30,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          )
                        : IconButton(
                            onPressed: controller.onSubmit,
                            icon: const Icon(Icons.done),
                          ),
                  ),
                ],
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
                                      profile: controller.inheritedProfile,
                                      radius: 100,
                                      image: controller.selectedBytes.value !=
                                              null
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: () =>
                                  controller.takePicture(ImageSource.camera),
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
                              onTap: () =>
                                  controller.takePicture(ImageSource.gallery),
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
                        ),
                        const Divider(height: 30),
                        CommonAsyncTextField(
                          callback: controller.onUsernameChanged,
                          label: 'Username',
                          duration: const Duration(milliseconds: 500),
                          asyncValidator: controller.asyncUsernameValidator,
                          syncValidator: controller.usernameValidator,
                          initialValue: controller.inheritedProfile.username,
                        ),
                        CommonTextField(
                          callback: controller.onBioChanged,
                          label: 'Bio (Optional)',
                          validator: controller.bioValidator,
                          initialValue: controller.inheritedProfile.bio,
                          maxLength: 1000,
                          maxLines: 10,
                          minLines: 3,
                        ),
                        const Divider(height: 20),
                        _showEmailToggleSwitch(controller),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        });
  }
}
