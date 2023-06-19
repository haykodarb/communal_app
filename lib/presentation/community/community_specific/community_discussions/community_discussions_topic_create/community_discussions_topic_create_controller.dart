import 'package:communal/backend/discussions_backend.dart';
import 'package:communal/models/backend_response.dart';
import 'package:communal/models/community.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CommunityDiscussionsTopicCreateController extends GetxController {
  final Community community = Get.arguments['community'];

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

  Future<void> onSubmit() async {
    if (formKey.currentState!.validate()) {
      loading.value = true;
      errorMessage.value = '';

      final BackendResponse response = await DiscussionsBackend.createDiscussionTopic(
        name: name.value,
        community: community,
      );

      loading.value = false;

      if (response.success) {
        Get.back<dynamic>(
          result: response.payload,
        );
      } else {
        errorMessage.value = 'Creating topic failed.';
      }
    }
  }
}
