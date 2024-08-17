import 'dart:io';

import 'package:communal/backend/communities_backend.dart';
import 'package:communal/models/backend_response.dart';
import 'package:communal/models/community.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class CommunityCreateController extends GetxController {
  final Rx<Community> communityForm = Community.empty().obs;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final RxBool loading = false.obs;
  final RxString errorMessage = ''.obs;

  final ImagePicker imagePicker = ImagePicker();
  final Rxn<File> selectedFile = Rxn<File>();

  void onNameChange(String value) {
    communityForm.update(
      (Community? val) {
        val!.name = value;
      },
    );
  }

  void onDescriptorChange(String value) {
    communityForm.value.description = value;
    communityForm.refresh();
  }

  Future<void> takePicture(ImageSource source) async {
    XFile? pickedImage = await imagePicker.pickImage(
      source: source,
      imageQuality: 100,
      maxHeight: 720,
      maxWidth: 1280,
    );

    if (pickedImage == null) return;

    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedImage.path,
      aspectRatio: const CropAspectRatio(ratioX: 16, ratioY: 9),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop',
          toolbarColor: Theme.of(Get.context!).colorScheme.surfaceContainer,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: true,
          hideBottomControls: true,
        ),
        IOSUiSettings(
          title: 'Crop',
        ),
      ],
    );

    if (croppedFile == null) return;

    selectedFile.value = File(croppedFile.path);
  }

  String? stringValidator(String? value, int length) {
    if (value == null || value.isEmpty) {
      return 'Please enter something.';
    }

    if (value.length < length) {
      return 'Must be at least $length characters long.';
    }

    return null;
  }

  Future<void> onSubmit() async {
    if (formKey.currentState!.validate()) {
      loading.value = true;
      errorMessage.value = '';

      final BackendResponse response = await CommunitiesBackend.createCommunity(
        communityForm.value,
        selectedFile.value,
      );

      loading.value = false;

      if (response.success) {
        Get.back<dynamic>(
          result: true,
        );
      } else {
        errorMessage.value = 'Creating Community failed.';
      }
    }
  }
}
