import 'dart:io';

import 'package:communal/backend/communities_backend.dart';
import 'package:communal/models/backend_response.dart';
import 'package:communal/models/community.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
