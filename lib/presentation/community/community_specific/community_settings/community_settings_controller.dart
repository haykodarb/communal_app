import 'dart:typed_data';
import 'package:communal/backend/communities_backend.dart';
import 'package:communal/backend/users_backend.dart';
import 'package:communal/models/backend_response.dart';
import 'package:communal/models/community.dart';
import 'package:communal/presentation/common/common_alert_dialog.dart';
import 'package:communal/presentation/common/common_confirmation_dialog.dart';
import 'package:communal/presentation/common/common_image_cropper.dart';
import 'package:communal/presentation/community/community_list_controller.dart';
import 'package:communal/presentation/community/community_specific/community_specific_controller.dart';
import 'package:communal/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class CommunitySettingsController extends GetxController {
  late Community community = Get.find<CommunitySpecificController>().community;

  final CommunitySpecificController communitySpecificController = Get.find();

  TextEditingController? textEditingController =
      TextEditingController.fromValue(
    TextEditingValue(
      text: Get.find<CommunitySpecificController>().community.name,
    ),
  );

  final RxBool edited = false.obs;

  final Rx<Community> communityForm = Community.empty().obs;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final RxBool loading = false.obs;
  final RxString errorMessage = ''.obs;

  final ImagePicker imagePicker = ImagePicker();
  final Rxn<Uint8List> selectedBytes = Rxn<Uint8List>();

  CommunityListController? communityListController;

  @override
  void onReady() {
    super.onReady();

    communityForm.value = Community.copy(community);

    if (Get.isRegistered<CommunityListController>()) {
      communityListController = Get.find<CommunityListController>();
    }

    communityForm.refresh();
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

    edited.value = true;

    _checkIfEdited();
  }

  String? stringValidator({
    required String? value,
    required int length,
    required bool optional,
  }) {
    if (optional) {
      if (value == null || value.isEmpty) return null;
    } else {
      if (value == null || value.isEmpty) {
        return 'Please enter something.';
      }
    }

    if (value.length < length) {
      return 'Must be at least $length characters long.';
    }

    return null;
  }

  Future<void> leaveCommunity(BuildContext context) async {
    final bool confirm = await CommonConfirmationDialog(
      title: 'Are you sure you want to leave community ${community.name}?',
    ).open(context);

    if (confirm) {
      final BackendResponse response =
          await UsersBackend.removeCurrentUserFromCommunity(community);

      if (context.mounted) {
        if (response.success) {
          communityListController?.listViewController.removeItem(
            (element) => element.id == community.id,
          );

          context.go(RouteNames.communityListPage);
        } else {
          CommonAlertDialog(
            title: response.payload,
          ).open(context);
        }
      }
    }
  }

  Future<void> deleteCommunity(BuildContext context) async {
    final bool confirm = await CommonConfirmationDialog(
      title: 'Confirm delete of community ${community.name}?',
    ).open(context);

    if (confirm) {
      final BackendResponse response =
          await CommunitiesBackend.deleteCommunity(community);

      if (context.mounted) {
        if (response.success) {
          communityListController?.listViewController.removeItem(
            (element) => element.id == community.id,
          );

          context.go(RouteNames.communityListPage);
        } else {
          CommonAlertDialog(title: response.payload).open(context);
        }
      }
    }
  }

  void _checkIfEdited() {
    bool matchesOriginal = communityForm.value.name == community.name &&
        communityForm.value.description == community.description &&
        selectedBytes.value == null;

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

  Future<void> onSubmit(BuildContext context) async {
    if (formKey.currentState!.validate()) {
      loading.value = true;
      errorMessage.value = '';
      final bool wasPinned = community.pinned.value;

      final BackendResponse response = await CommunitiesBackend.updateCommunity(
        communityForm.value,
        selectedBytes.value,
      );

      if (response.success) {
        community = response.payload;
        community.pinned.value = wasPinned;
        communitySpecificController.community = community;

        selectedBytes.value = null;
        _checkIfEdited();

        int? index =
            communityListController?.listViewController.itemList.indexWhere(
          (element) => element.id == communityForm.value.id,
        );

        if (index != null && index >= 0) {
          communityListController?.listViewController.itemList[index] =
              community;
        }

        communityListController?.listViewController.itemList.refresh();

        loading.value = false;
      } else {
        if (context.mounted) {
          CommonAlertDialog(
            title: response.payload,
          ).open(context);
        }
      }
    }
  }
}
