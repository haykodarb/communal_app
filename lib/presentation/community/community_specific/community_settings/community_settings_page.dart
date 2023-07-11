import 'package:communal/backend/communities_backend.dart';
import 'package:communal/presentation/common/common_loading_image.dart';
import 'package:communal/presentation/community/community_specific/community_settings/community_settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class CommunitySettingsPage extends StatelessWidget {
  const CommunitySettingsPage({super.key});

  Widget _communityAvatar(CommunitySettingsController controller) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: FutureBuilder(
        future: CommunitiesBackend.getCommunityAvatar(controller.community),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const CommonLoadingImage();
          }

          if (snapshot.data!.isEmpty) {
            return Container(
              color: Theme.of(context).colorScheme.primary,
              child: Icon(
                Icons.groups,
                color: Theme.of(context).colorScheme.background,
                size: 150,
              ),
            );
          }

          return Image.memory(
            snapshot.data!,
            fit: BoxFit.cover,
          );
        },
      ),
    );
  }

  Widget _ownerBottomRowButtons(CommunitySettingsController controller) {
    return Builder(
      builder: (context) {
        return Row(
          children: [
            // Expanded(
            //   child: Obx(
            //     () {
            //       return ElevatedButton(
            //         onPressed: controller.editing.value ? () {} : controller.enableEditing,
            //         child: Text(controller.editing.value ? 'Save' : 'Edit'),
            //       );
            //     },
            //   ),
            // ),
            const VerticalDivider(),
            Expanded(
              child: Obx(
                () {
                  return OutlinedButton(
                    onPressed: controller.editing.value ? controller.cancelEditing : controller.deleteCommunity,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: controller.editing.value ? null : Theme.of(context).colorScheme.error,
                      side: BorderSide(
                        color: controller.editing.value
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.error,
                      ),
                    ),
                    child: Text(
                      controller.editing.value ? 'Cancel' : 'Delete',
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _memberBottomRowButtons(CommunitySettingsController controller) {
    return Builder(
      builder: (context) {
        return OutlinedButton(
          onPressed: controller.leaveCommunity,
          style: OutlinedButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.error,
            side: BorderSide(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          child: const Text(
            'Leave',
          ),
        );
      },
    );
  }

  Widget _communityNameField(CommunitySettingsController controller) {
    return Builder(
      builder: (context) {
        return Obx(
          () {
            return TextField(
              controller: controller.textEditingController,
              enabled: controller.editing.value,
              style: TextStyle(
                color: controller.editing.value
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onBackground,
              ),
              decoration: InputDecoration(
                disabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _selectNewAvatar(CommunitySettingsController controller) {
    return Builder(
      builder: (context) {
        return Obx(
          () => Visibility(
            visible: controller.editing.value,
            child: SizedBox(
              height: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Select new avatar',
                    style: TextStyle(fontSize: 18),
                  ),
                  const VerticalDivider(),
                  IconButton(
                    onPressed: () => controller.takePicture(ImageSource.camera),
                    icon: Icon(Icons.camera_alt, size: 30, color: Theme.of(context).colorScheme.primary),
                  ),
                  const VerticalDivider(),
                  IconButton(
                    onPressed: () => controller.takePicture(ImageSource.gallery),
                    icon: Icon(Icons.image, size: 30, color: Theme.of(context).colorScheme.primary),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: CommunitySettingsController(),
      builder: (controller) {
        return CustomScrollView(
          slivers: [
            SliverFillRemaining(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        _communityNameField(controller),
                        const Divider(height: 30),
                        _communityAvatar(controller),
                        const Divider(height: 30),
                        _selectNewAvatar(controller),
                      ],
                    ),
                    controller.community.isCurrentUserOwner
                        ? _ownerBottomRowButtons(controller)
                        : _memberBottomRowButtons(controller),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
