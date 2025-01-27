import 'package:atlas_icons/atlas_icons.dart';
import 'package:communal/backend/communities_backend.dart';
import 'package:communal/presentation/common/common_loading_body.dart';
import 'package:communal/presentation/common/common_loading_image.dart';
import 'package:communal/presentation/common/common_text_field.dart';
import 'package:communal/presentation/community/community_specific/community_settings/community_settings_controller.dart';
import 'package:communal/presentation/community/community_specific/community_specific_controller.dart';
import 'package:communal/responsive.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class CommunitySettingsPage extends StatelessWidget {
  const CommunitySettingsPage({
    super.key,
  });

  Widget _imageSelector(CommunitySettingsController controller) {
    return Builder(builder: (context) {
      return Container(
        width: 300,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
        ),
        clipBehavior: Clip.hardEdge,
        child: AspectRatio(
          aspectRatio: 1,
          child: Stack(
            children: [
              SizedBox(
                width: double.maxFinite,
                height: double.maxFinite,
                child: Obx(
                  () {
                    if (controller.selectedBytes.value != null) {
                      return Image.memory(
                        controller.selectedBytes.value!,
                        fit: BoxFit.cover,
                      );
                    } else {
                      if (controller.community.image_path != null) {
                        return FutureBuilder(
                          future: CommunitiesBackend.getCommunityAvatar(
                            controller.community,
                          ),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const CommonLoadingImage();
                            }

                            if (snapshot.data!.isEmpty) {
                              return Container(
                                color: Theme.of(context).colorScheme.primary,
                                child: Icon(
                                  Atlas.users,
                                  color: Theme.of(context).colorScheme.surface,
                                  size: 150,
                                ),
                              );
                            }

                            return Image.memory(
                              snapshot.data!,
                              fit: BoxFit.cover,
                            );
                          },
                        );
                      }

                      return Card(
                        margin: EdgeInsets.zero,
                        color: Theme.of(context).colorScheme.surfaceContainer,
                        child: const Center(
                          child: Text(
                            'No\nimage',
                            style: TextStyle(fontSize: 18),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
              Visibility(
                visible: controller.community.isCurrentUserOwner,
                child: Container(
                  width: double.maxFinite,
                  padding: const EdgeInsets.only(bottom: 20),
                  alignment: Alignment.bottomCenter,
                  child: Obx(
                    () {
                      final bool imageExists =
                          controller.selectedBytes.value != null || controller.community.image_path != null;

                      final Color buttonBackground = imageExists
                          ? Theme.of(context).colorScheme.surfaceContainer
                          : Theme.of(context).colorScheme.primary;

                      final Color iconColor =
                          imageExists ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onPrimary;

                      final Border? buttonBorder =
                          imageExists ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2) : null;

                      if (kIsWeb) {
                        return InkWell(
                          onTap: () => controller.takePicture(
                            ImageSource.gallery,
                            context,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              border: buttonBorder,
                              borderRadius: BorderRadius.circular(10),
                              color: buttonBackground,
                            ),
                            padding: const EdgeInsets.all(13),
                            child: Icon(
                              Atlas.image_gallery,
                              color: iconColor,
                              size: 24,
                            ),
                          ),
                        );
                      }

                      return Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () => controller.takePicture(
                              ImageSource.camera,
                              context,
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                border: buttonBorder,
                                borderRadius: BorderRadius.circular(10),
                                color: buttonBackground,
                              ),
                              padding: const EdgeInsets.all(13),
                              child: Icon(
                                Atlas.camera,
                                weight: 400,
                                color: iconColor,
                                size: 24,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () => controller.takePicture(
                              ImageSource.gallery,
                              context,
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                border: buttonBorder,
                                borderRadius: BorderRadius.circular(10),
                                color: buttonBackground,
                              ),
                              padding: const EdgeInsets.all(13),
                              child: Icon(
                                Atlas.image_gallery,
                                color: iconColor,
                                size: 24,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _bottomRowButtons(CommunitySettingsController controller) {
    return Builder(
      builder: (context) {
        final bool userIsOwner = controller.community.isCurrentUserOwner;
        return Obx(
          () {
            return CommonLoadingBody(
              loading: controller.loading.value,
              child: Stack(
                children: [
                  Visibility(
                    visible: !userIsOwner,
                    child: OutlinedButton(
                      onPressed: () => controller.leaveCommunity(context),
                      child: const Text('Leave'),
                    ),
                  ),
                  Visibility(
                    visible: userIsOwner,
                    child: Row(
                      children: [
                        Expanded(
                          child: Obx(
                            () {
                              return ElevatedButton(
                                onPressed: controller.edited.value ? () => controller.onSubmit(context) : null,
                                child: const Text(
                                  'Save',
                                ),
                              );
                            },
                          ),
                        ),
                        const VerticalDivider(width: 10),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => controller.deleteCommunity(context),
                            child: const Text(
                              'Delete',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        final CommunitySpecificController specificController = Get.find();
        if (specificController.loading.value) {
          return const CommonLoadingBody();
        }

        return GetBuilder(
          init: CommunitySettingsController(),
          builder: (controller) {
            return Scaffold(
              resizeToAvoidBottomInset: false,
              appBar: AppBar(
                title: Responsive.isMobile(context) ? const Text('Settings') : null,
              ),
              body: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                child: Form(
                  key: controller.formKey,
                  child: Column(
                    children: [
                      _imageSelector(controller),
                      const Divider(height: 20),
                      CommonTextField(
                        enabled: controller.community.isCurrentUserOwner,
                        callback: controller.onNameChange,
                        submitCallback: (_) => controller.onSubmit(context),
                        label: 'Name',
                        initialValue: controller.community.name,
                        validator: (value) => controller.stringValidator(
                          value: value,
                          length: 4,
                          optional: false,
                        ),
                      ),
                      Visibility(
                        visible: controller.community.isCurrentUserOwner || controller.community.description != null,
                        child: CommonTextField(
                          enabled: controller.community.isCurrentUserOwner,
                          callback: controller.onDescriptorChange,
                          submitCallback: (_) => controller.onSubmit(context),
                          label: 'Description (Optional)',
                          initialValue: controller.community.description,
                          minLines: 5,
                          maxLines: 10,
                          validator: (value) => controller.stringValidator(
                            value: value,
                            length: 4,
                            optional: true,
                          ),
                        ),
                      ),
                      const Divider(height: 20),
                      _bottomRowButtons(controller),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
