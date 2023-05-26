import 'package:biblioteca/backend/communities_backend.dart';
import 'package:biblioteca/models/backend_response.dart';
import 'package:biblioteca/models/community.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CreateCommunityController extends GetxController {
  final Rx<Community> communityForm = Community(name: '', description: '').obs;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final RxBool loading = false.obs;
  final RxString errorMessage = ''.obs;

  void onNameChange(String value) {
    communityForm.update(
      (Community? val) {
        val!.name = value;
      },
    );
  }

  void onDescriptionChange(String value) {
    communityForm.update(
      (Community? val) {
        val!.description = value;
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

  Future<void> onSubmit() async {
    if (formKey.currentState!.validate()) {
      loading.value = true;
      errorMessage.value = '';

      final BackendReponse response = await CommunitiesBackend.createCommunity(communityForm.value);

      loading.value = false;
      if (response.success) {
        errorMessage.value = 'Community created.';

        Get.back<dynamic>(
          result: true,
        );
      } else {
        errorMessage.value = 'Creating Community failed.';
      }
    }
  }
}
