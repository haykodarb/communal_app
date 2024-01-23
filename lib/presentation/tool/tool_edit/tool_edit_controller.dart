import 'dart:io';
import 'package:communal/backend/tools_backend.dart';
import 'package:communal/models/backend_response.dart';
import 'package:communal/models/tool.dart';
import 'package:communal/presentation/common/common_alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ToolEditController extends GetxController {
  final Tool inheritedTool = Get.arguments['tool'];

  final Rx<Tool> toolForm = Tool.empty().obs;

  final RxBool allowReview = false.obs;
  final RxBool addingReview = false.obs;

  final RxBool loading = false.obs;

  final ImagePicker imagePicker = ImagePicker();
  final Rxn<File> selectedFile = Rxn<File>();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Future<void> onInit() async {
    super.onInit();

    toolForm.value = inheritedTool;
    toolForm.refresh();
  }

  Future<void> takePicture(ImageSource source) async {
    XFile? pickedImage = await imagePicker.pickImage(
      source: source,
      imageQuality: 100,
      maxHeight: 1280,
      maxWidth: 960,
      preferredCameraDevice: CameraDevice.rear,
    );

    if (pickedImage == null) return;

    selectedFile.value = File(pickedImage.path);
  }

  void onDescriptionChange(String? value) {
    toolForm.update(
      (Tool? val) {
        val!.description = value ?? '';
      },
    );
  }

  void onAvailableChange(int? index) {
    toolForm.update(
      (Tool? val) {
        val!.available = index == 0 ? true : false;
      },
    );
  }

  void onNameChange(String value) {
    toolForm.update(
      (Tool? val) {
        val!.name = value;
      },
    );
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

  Future<void> onSubmitButton() async {
    if (formKey.currentState!.validate()) {
      loading.value = true;

      final BackendResponse response = await ToolsBackend.updateTool(
        toolForm.value,
        selectedFile.value == null ? null : File(selectedFile.value!.path),
      );

      loading.value = false;

      if (response.success) {
        Get.back<Tool>(
          result: response.payload,
        );
      } else {
        Get.dialog(CommonAlertDialog(title: response.payload));
      }
    }
  }
}
