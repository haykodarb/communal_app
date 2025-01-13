import 'dart:typed_data';
import 'package:communal/backend/communities_backend.dart';
import 'package:communal/models/backend_response.dart';
import 'package:communal/models/community.dart';
import 'package:communal/presentation/common/common_image_cropper.dart';
import 'package:communal/presentation/community/community_list_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class CommunityCreateController extends GetxController {
  final Rx<Community> communityForm = Community.empty().obs;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final RxBool loading = false.obs;
  final RxString errorMessage = ''.obs;

  final ImagePicker imagePicker = ImagePicker();
  final Rxn<Uint8List> selectedBytes = Rxn<Uint8List>();

  final CommunityListController communityListController = Get.find();

  void onNameChange(String value) {
    communityForm.update(
      (Community? val) {
        val!.name = value;
      },
    );
  }

  void onDescriptorChange(String value) {
    communityForm.update(
      (Community? val) {
        val!.description = value;
      },
    );
  }

  Future<void> takePicture(ImageSource source, BuildContext context) async {
    XFile? pickedImage = await imagePicker.pickImage(
      source: source,
      imageQuality: 100,
      maxHeight: 1280,
      maxWidth: 1280,
    );

    if (pickedImage == null) return;
    final Uint8List bytes = await pickedImage.readAsBytes();

    if (!context.mounted) return;

    final Uint8List? croppedBytes = await showDialog<Uint8List?>(
      context: context,
      builder: (context) => CommonImageCropper(
        image: Image.memory(bytes),
        aspectRatio: 1,
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

  Future<void> onSubmit(BuildContext context) async {
    if (formKey.currentState!.validate()) {
      loading.value = true;
      errorMessage.value = '';

      final BackendResponse<Community> response =
          await CommunitiesBackend.createCommunity(
        communityForm.value,
        selectedBytes.value,
      );

      loading.value = false;

      if (response.success && context.mounted) {
        communityListController.listViewController.addItem(response.payload!);
        context.pop(true);
      } else {
        errorMessage.value = 'Creating Community failed.';
      }
    }
  }
}
