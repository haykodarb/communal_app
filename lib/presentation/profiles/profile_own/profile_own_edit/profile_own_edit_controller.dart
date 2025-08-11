import 'dart:async';
import 'dart:typed_data';
import 'package:communal/backend/users_backend.dart';
import 'package:communal/models/backend_response.dart';
import 'package:communal/models/profile.dart';
import 'package:communal/presentation/common/common_alert_dialog.dart';
import 'package:communal/presentation/common/common_drawer/common_drawer_controller.dart';
import 'package:communal/presentation/common/common_image_cropper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide debounce;
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:string_validator/string_validator.dart';

class ProfileOwnEditController extends GetxController {
  final Rx<Profile> inheritedProfile = Get.find<CommonDrawerController>().currentUserProfile;

  final ImagePicker imagePicker = ImagePicker();
  final Rxn<Uint8List> selectedBytes = Rxn<Uint8List>();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final RxBool loading = false.obs;
  final RxBool addBio = false.obs;
  final RxBool usernameAvailable = true.obs;

  RxString newUsername = ''.obs;
  RxnString newBio = RxnString();
  final RxBool newShowEmail = false.obs;

  Timer? debounce;

  @override
  void onInit() {
    super.onInit();

    newUsername.value = inheritedProfile.value.username;
    newBio.value = inheritedProfile.value.bio;
    addBio.value = inheritedProfile.value.bio != null;
    newShowEmail.value = inheritedProfile.value.show_email;

    inheritedProfile.listen(
      (Profile profile) {
        newUsername.value = inheritedProfile.value.username;
        newBio.value = inheritedProfile.value.bio;
        addBio.value = inheritedProfile.value.bio != null;
        newShowEmail.value = inheritedProfile.value.show_email;
      },
    );
  }

  Future<void> takePicture(ImageSource source, BuildContext context) async {
    XFile? pickedImage = await imagePicker.pickImage(
      source: source,
      imageQuality: 80,
      maxHeight: 320,
      maxWidth: 320,
      preferredCameraDevice: CameraDevice.rear,
    );

    if (pickedImage == null) return;
    final Uint8List pickedBytes = await pickedImage.readAsBytes();

    if (!context.mounted) return;
    final Uint8List? croppedBytes = await CommonImageCropper(
      image: Image.memory(pickedBytes),
      aspectRatio: 1,
    ).open(context);

    if (croppedBytes == null) return;

    selectedBytes.value = croppedBytes;
    selectedBytes.refresh();
  }

  void onUsernameChanged(String value) {
    newUsername.value = value;
  }

  void onBioChanged(String value) {
    if (value.isEmpty) {
      newBio.value = null;
    } else {
      newBio.value = value;
    }
  }

  void onShowEmailChanged() {
    newShowEmail.value = !newShowEmail.value;
  }

  void onAddBioChanged(int? value) {
    if (value == null) return;

    addBio.value = value == 0;
  }

  Future<String?> asyncUsernameValidator(String? value) async {
    if (value == null) {
      return 'Input can\'t be empty';
    }

    if (value == inheritedProfile.value.username) return null;

    final bool available = await UsersBackend.validateUsername(value);

    if (!available) {
      return 'Username is already taken.';
    }

    return null;
  }

  String? usernameValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter something'.tr;
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

  Future<void> onSubmit(BuildContext context) async {
    if (formKey.currentState!.validate()) {
      loading.value = true;

      Profile newProfile = Profile.copy(inheritedProfile.value);

      newProfile.show_email = newShowEmail.value;
      newProfile.bio = newBio.value;
      newProfile.username = newUsername.value;

      final BackendResponse response = await UsersBackend.updateProfile(
        newProfile,
        selectedBytes.value,
      );

      loading.value = false;

      if (response.success) {
        Get.find<CommonDrawerController>().currentUserProfile.value = response.payload;
      }

      if (context.mounted) {
        if (response.success) {
          context.pop(response.payload);
        } else {
          CommonAlertDialog(title: response.payload).open(context);
        }
      }
    }
  }
}
