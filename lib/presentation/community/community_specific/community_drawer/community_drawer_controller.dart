import 'package:communal/backend/communities_backend.dart';
import 'package:communal/models/backend_response.dart';
import 'package:communal/models/community.dart';
import 'package:communal/presentation/common/common_alert_dialog.dart';
import 'package:communal/presentation/common/common_confirmation_dialog.dart';
import 'package:communal/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CommunityDrawerController extends GetxController {
  CommunityDrawerController(this.community);

  final Community community;

  final RxBool loading = true.obs;

  @override
  Future<void> onInit() async {
    super.onInit();

    loading.value = false;
  }

  Future<void> deleteCommunity() async {
    final bool? confirm = await Get.dialog(
      CommonConfirmationDialog(
        title: 'Confirm delete of community ${community.name}?',
      ),
    );

    if (confirm != null && confirm) {
      final BackendResponse response = await CommunitiesBackend.deleteCommunity(community);

      if (response.success) {
        Navigator.popUntil(Get.context!, (route) => route.isFirst);
      } else {
        Get.dialog(
          const CommonAlertDialog(title: 'Could not delete community.'),
        );
      }
    }
  }
}
