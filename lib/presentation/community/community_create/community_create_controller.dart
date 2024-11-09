import 'dart:typed_data';
import 'package:communal/backend/communities_backend.dart';
import 'package:communal/models/backend_response.dart';
import 'package:communal/models/community.dart';
import 'package:communal/presentation/common/common_image_cropper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class CommunityCreateController extends GetxController {
  final Rx<Community> communityForm = Community.empty().obs;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final RxBool loading = false.obs;
  final RxString errorMessage = ''.obs;

  final ImagePicker imagePicker = ImagePicker();
  final Rxn<Uint8List> selectedBytes = Rxn<Uint8List>();

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

    final Uint8List? croppedBytes = await Get.dialog<Uint8List?>(
      CommonImageCropper(
        image: Image.memory(await pickedImage.readAsBytes()),
        aspectRatio: 2,
      ),
    );

    if (croppedBytes == null || croppedBytes.isEmpty) return;

    selectedBytes.value = croppedBytes;
  }

  String? stringValidator(String? value, int length, bool optional) {
    if ((value == null || value.isEmpty) && !optional) {
      return 'Please enter something.';
    }

    if (optional && (value == null || value.isEmpty)) return null;

    if (value != null && value.length < length) {
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
        selectedBytes.value,
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
