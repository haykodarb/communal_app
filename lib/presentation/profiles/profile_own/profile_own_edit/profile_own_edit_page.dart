import 'dart:io';
import 'package:communal/presentation/common/common_async_text_field.dart';
import 'package:communal/presentation/common/common_circular_avatar.dart';
import 'package:communal/presentation/common/common_text_field.dart';
import 'package:communal/presentation/profiles/profile_own/profile_own_edit/profile_own_edit_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:toggle_switch/toggle_switch.dart';

class ProfileOwnEditPage extends StatelessWidget {
  const ProfileOwnEditPage({super.key});

  Widget _addBioToggleSwitch(ProfileOwnEditController controller) {
    return Builder(
      builder: (context) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Add bio?',
              style: TextStyle(fontSize: 14),
            ),
            const Divider(),
            ToggleSwitch(
              minWidth: 60,
              minHeight: 40,
              cornerRadius: 4,
              borderColor: [Theme.of(context).colorScheme.onBackground],
              borderWidth: 0.75,
              activeBgColors: [
                [Theme.of(context).colorScheme.primary],
                [Theme.of(context).colorScheme.error]
              ],
              activeFgColor: Theme.of(context).colorScheme.onBackground,
              inactiveBgColor: Theme.of(context).colorScheme.surface,
              inactiveFgColor: Theme.of(context).colorScheme.onBackground,
              initialLabelIndex: controller.inheritedProfile.bio != null ? 0 : 1,
              totalSwitches: 2,
              iconSize: 60,
              icons: const [Icons.done, Icons.close],
              radiusStyle: true,
              onToggle: controller.onAddBioChanged,
            ),
          ],
        );
      },
    );
  }

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
            ToggleSwitch(
              minWidth: 60,
              minHeight: 40,
              cornerRadius: 4,
              borderColor: [Theme.of(context).colorScheme.onBackground],
              borderWidth: 0.75,
              activeBgColors: [
                [Theme.of(context).colorScheme.primary],
                [Theme.of(context).colorScheme.error]
              ],
              activeFgColor: Theme.of(context).colorScheme.onBackground,
              inactiveBgColor: Theme.of(context).colorScheme.surface,
              inactiveFgColor: Theme.of(context).colorScheme.onBackground,
              initialLabelIndex: controller.inheritedProfile.show_email ? 0 : 1,
              totalSwitches: 2,
              iconSize: 60,
              icons: const [Icons.done, Icons.close],
              radiusStyle: true,
              onToggle: controller.onShowEmailChanged,
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
              title: const Text('Edit profile'),
              actions: [
                Obx(
                  () => controller.loading.value
                      ? SizedBox(
                          width: 30,
                          height: 30,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Theme.of(context).colorScheme.onBackground,
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
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                child: Form(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  key: controller.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 250,
                        width: 250,
                        child: Stack(
                          children: [
                            Align(
                              alignment: Alignment.topRight,
                              child: Obx(
                                () => Visibility(
                                  visible: controller.selectedFile.value != null,
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.close,
                                      color: Theme.of(context).colorScheme.error,
                                    ),
                                    iconSize: 40,
                                    onPressed: () {
                                      controller.selectedFile.value = null;
                                    },
                                  ),
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: Obx(
                                () {
                                  return CommonCircularAvatar(
                                    profile: controller.inheritedProfile,
                                    radius: 100,
                                    image: controller.selectedFile.value != null
                                        ? Image.file(
                                            File(controller.selectedFile.value!.path),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                  );
                                },
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                color: Colors.black.withOpacity(0.5),
                                width: double.maxFinite,
                                height: 75,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      onPressed: () => controller.takePicture(ImageSource.camera),
                                      icon: const Icon(
                                        Icons.camera_alt,
                                        color: Colors.white,
                                        size: 40,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () => controller.takePicture(ImageSource.gallery),
                                      icon: const Icon(
                                        Icons.image,
                                        color: Colors.white,
                                        size: 40,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
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
                      const Divider(height: 30),
                      _showEmailToggleSwitch(controller),
                      const Divider(height: 30),
                      _addBioToggleSwitch(controller),
                      const Divider(height: 30),
                      Obx(
                        () => Visibility(
                          visible: controller.addBio.value,
                          child: CommonTextField(
                            callback: controller.onBioChanged,
                            label: 'Bio',
                            validator: controller.bioValidator,
                            initialValue: controller.inheritedProfile.bio,
                            maxLength: 1000,
                            maxLines: 100,
                          ),
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
