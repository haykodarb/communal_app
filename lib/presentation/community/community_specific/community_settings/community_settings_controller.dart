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
  Community community = Get.arguments['community'];

  final TextEditingController textEditingController =
      TextEditingController.fromValue(
    TextEditingValue(
      text: (Get.arguments['community'] as Community).name,
    ),
  );

  final RxBool edited = false.obs;

  final Rx<Community> communityForm = Community.empty().obs;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final RxBool loading = false.obs;
  final RxString errorMessage = ''.obs;

  final ImagePicker imagePicker = ImagePicker();
  final Rxn<File> selectedFile = Rxn<File>();

  @override
  void onInit() {
    super.onInit();
    communityForm.value = Community.copy(community);

    communityForm.refresh();
  }

  Future<void> takePicture(ImageSource source) async {
    XFile? pickedImage = await imagePicker.pickImage(
      source: source,
      imageQuality: 80,
      maxHeight: 720,
      maxWidth: 1280,
    );

    if (pickedImage == null) return;

    edited.value = true;
    selectedFile.value = File(pickedImage.path);

    _checkIfEdited();
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

  Future<void> leaveCommunity() async {
    final bool? confirm = await Get.dialog(
      CommonConfirmationDialog(
        title: 'Are you sure you want to leave community ${community.name}?',
      ),
    );

    if (confirm != null && confirm) {
      final BackendResponse response =
          await UsersBackend.removeCurrentUserFromCommunity(community);

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
      final BackendResponse response =
          await CommunitiesBackend.deleteCommunity(community);

      if (response.success) {
        Get.back();
      } else {
        Get.dialog(
          CommonAlertDialog(title: response.payload),
        );
      }
    }
  }

  void _checkIfEdited() {
    bool matchesOriginal = communityForm.value.name == community.name &&
        communityForm.value.description == community.description &&
        selectedFile.value == null;

    edited.value = !matchesOriginal;
  }

  void onNameChange(String value) {
    communityForm.update(
      (Community? val) {
        val!.name = value;
      },
    );

    _checkIfEdited();
  }

  void onDescriptorChange(String value) {
    communityForm.value.description = value;

    if (value.isEmpty) {
      communityForm.value.description = null;
    }

    communityForm.refresh();

    _checkIfEdited();
  }

  Future<void> onSubmit() async {
    if (formKey.currentState!.validate()) {
      loading.value = true;
      errorMessage.value = '';

      final BackendResponse response = await CommunitiesBackend.updateCommunity(
        communityForm.value,
        selectedFile.value,
      );

      if (response.success) {
        community = Community.copy(communityForm.value);
	_checkIfEdited();
        loading.value = false;
      } else {
        Get.dialog(
          CommonAlertDialog(
            title: response.payload,
          ),
        );
      }
    }
  }
}
