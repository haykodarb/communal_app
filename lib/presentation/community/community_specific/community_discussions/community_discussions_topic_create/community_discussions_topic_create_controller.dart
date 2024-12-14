import 'package:communal/backend/discussions_backend.dart';
import 'package:communal/models/backend_response.dart';
import 'package:communal/presentation/community/community_specific/community_discussions/community_discussions_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

class CommunityDiscussionsTopicCreateController extends GetxController {
  CommunityDiscussionsTopicCreateController({required this.communityId});
  final String communityId;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final RxBool loading = false.obs;
  final RxString errorMessage = ''.obs;

  final RxString name = ''.obs;

  void onNameChange(String value) {
    name.value = value;
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

  Future<void> onSubmit(BuildContext context) async {
    if (formKey.currentState!.validate()) {
      loading.value = true;
      errorMessage.value = '';

      final BackendResponse response = await DiscussionsBackend.createDiscussionTopic(
        name: name.value,
        communityId: communityId,
      );

      loading.value = false;

      if (response.success) {
        final CommunityDiscussionsController communityDiscussionsController = Get.find();

        communityDiscussionsController.listViewController.addItem(response.payload);
        if (context.mounted) {
          context.pop();
        }
      } else {
        errorMessage.value = 'Creating topic failed.';
      }
    }
  }
}
