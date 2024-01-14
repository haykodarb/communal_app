import 'dart:async';
import 'dart:io';
import 'package:communal/backend/users_backend.dart';
import 'package:communal/models/backend_response.dart';
import 'package:communal/models/profile.dart';
import 'package:communal/presentation/common/common_alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide debounce;
import 'package:image_picker/image_picker.dart';
import 'package:string_validator/string_validator.dart';

class ProfileOwnEditController extends GetxController {
  final Profile inheritedProfile = Get.arguments['profile'];
  Rx<Profile> profileForm = Profile.empty().obs;

  final ImagePicker imagePicker = ImagePicker();
  final Rxn<File> selectedFile = Rxn<File>();

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
      maxHeight: 250,
      maxWidth: 250,
      preferredCameraDevice: CameraDevice.rear,
    );

    if (pickedImage == null) return;

    selectedFile.value = File(pickedImage.path);
    selectedFile.refresh();
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

  void onShowEmailChanged(int? value) {
    if (value == null) return;

    profileForm.update((val) {
      val!.show_email = value == 0;
    });
  }

  void onAddBioChanged(int? value) {
    if (value == null) return;

    addBio.value = value == 0;
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

    bool available = true;

    if (debounce?.isActive ?? false) {
      debounce?.cancel();
    }

    debounce = Timer(
      const Duration(milliseconds: 500),
      () async {
        // if (value == inheritedProfile.username) {
        //   available = true;
        //   return;
        // }

        final bool usernameAvailable = await UsersBackend.validateUsername(value);

        available = usernameAvailable;
      },
    );

    if (!available) {
      return 'Username is not available';
    }

    return null;
  }

  String? bioValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter something.';
    }

    if (value.length < 6) {
      return 'Bio must be at least 6 characters long';
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
        selectedFile.value == null ? null : File(selectedFile.value!.path),
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
