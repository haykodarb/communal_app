import 'dart:async';
import 'dart:typed_data';
import 'package:communal/backend/users_backend.dart';
import 'package:communal/models/backend_response.dart';
import 'package:communal/models/profile.dart';
import 'package:communal/presentation/common/common_alert_dialog.dart';
import 'package:communal/presentation/common/common_image_cropper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide debounce;
import 'package:image_picker/image_picker.dart';
import 'package:string_validator/string_validator.dart';

class ProfileOwnEditController extends GetxController {
  final Profile inheritedProfile = Get.arguments['profile'];
  Rx<Profile> profileForm = Profile.empty().obs;

  final ImagePicker imagePicker = ImagePicker();
  final Rxn<Uint8List> selectedBytes = Rxn<Uint8List>();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final RxBool loading = false.obs;
  final RxBool addBio = false.obs;
  final RxBool usernameAvailable = true.obs;

  Timer? debounce;

  @override
  void onInit() {
    super.onInit();

    profileForm.value = Profile.copy(inheritedProfile);
    profileForm.refresh();

    addBio.value = inheritedProfile.bio != null;
  }

  Future<void> takePicture(ImageSource source) async {
    XFile? pickedImage = await imagePicker.pickImage(
      source: source,
      imageQuality: 80,
      maxHeight: 750,
      maxWidth: 750,
      preferredCameraDevice: CameraDevice.rear,
    );

    if (pickedImage == null) return;

    final Uint8List? croppedBytes = await Get.dialog<Uint8List?>(
      CommonImageCropper(
        image: Image.memory(await pickedImage.readAsBytes()),
        aspectRatio: 1,
      ),
    );

    if (croppedBytes == null) return;

    selectedBytes.value = croppedBytes;
    selectedBytes.refresh();
  }

  void onUsernameChanged(String value) {
    profileForm.update((val) {
      val!.username = value;
    });
  }

  void onBioChanged(String value) {
    profileForm.update((val) {
      val!.bio = value;
    });
  }

  void onShowEmailChanged() {
    profileForm.update((val) {
      val!.show_email = !val.show_email;
    });
  }

  void onAddBioChanged(int? value) {
    if (value == null) return;

    addBio.value = value == 0;
  }

  Future<String?> asyncUsernameValidator(String? value) async {
    if (value == null) {
      return 'Input can\'t be empty';
    }

    if (value == inheritedProfile.username) return null;

    final bool available = await UsersBackend.validateUsername(value);

    if (!available) {
      return 'Username is already taken.';
    }

    return null;
  }

  String? usernameValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter something.';
    }

    if (value.length < 6) {
      return 'Username must be at least 6 characters long';
    }

    if (value.length > 20) {
      return 'Username must be at most 20 characters long';
    }

    if (!isAscii(value)) {
      return 'Username should only include ASCII characters';
    }

    return null;
  }

  String? bioValidator(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    if (value.length < 20) {
      return 'Bio must be at least 20 characters long';
    }

    if (value.length > 1000) {
      return 'Bio must be at most 1000 characters long';
    }

    return null;
  }

  Future<void> onSubmit() async {
    if (formKey.currentState!.validate()) {
      loading.value = true;

      if (!addBio.value) {
        profileForm.update((val) {
          val!.bio = null;
        });
      }

      final BackendResponse response = await UsersBackend.updateProfile(
        profileForm.value,
        selectedBytes.value,
      );

      loading.value = false;

      if (response.success) {
        Get.back<Profile>(
          result: response.payload,
        );
      } else {
        Get.dialog(CommonAlertDialog(title: response.payload));
      }
    }
  }
}
