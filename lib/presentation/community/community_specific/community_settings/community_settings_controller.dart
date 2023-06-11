import 'dart:io';

import 'package:communal/backend/communities_backend.dart';
import 'package:communal/backend/users_backend.dart';
import 'package:communal/models/backend_response.dart';
import 'package:communal/models/community.dart';
import 'package:communal/presentation/common/common_alert_dialog.dart';
import 'package:communal/presentation/common/common_confirmation_dialog.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class CommunitySettingsController extends GetxController {
  final Community community = Get.arguments['community'];

  final TextEditingController textEditingController = TextEditingController.fromValue(
    TextEditingValue(
      text: (Get.arguments['community'] as Community).name,
    ),
  );

  final RxBool editing = false.obs;

  final ImagePicker imagePicker = ImagePicker();
  final Rxn<File> selectedFile = Rxn<File>();

  Future<void> takePicture(ImageSource source) async {
    XFile? pickedImage = await imagePicker.pickImage(
      source: source,
      imageQuality: 80,
      maxHeight: 720,
      maxWidth: 1280,
    );

    if (pickedImage == null) return;

    selectedFile.value = File(pickedImage.path);
  }

  void enableEditing() {
    editing.value = true;
  }

  void cancelEditing() {
    editing.value = false;
    textEditingController.text = community.name;
  }

  Future<void> leaveCommunity() async {
    final bool? confirm = await Get.dialog(
      CommonConfirmationDialog(
        title: 'Are you sure you want to leave community ${community.name}?',
      ),
    );

    if (confirm != null && confirm) {
      final BackendResponse response = await UsersBackend.removeCurrentUserFromCommunity(community);

      if (response.success) {
        Get.back();
      } else {
        Get.dialog(
          const CommonAlertDialog(title: 'Could not leave community.'),
        );
      }
    }
  }

  Future<void> deleteCommunity() async {
    final bool? confirm = await Get.dialog(
      CommonConfirmationDialog(
        title: 'Confirm delete of community ${community.name}?',
      ),
    );

    if (confirm != null && confirm) {
      final BackendResponse response = await CommunitiesBackend.deleteCommunity(community);

      if (response.success) {
        Get.back();
      } else {
        Get.dialog(
          const CommonAlertDialog(title: 'Could not delete community.'),
        );
      }
    }
  }
}
