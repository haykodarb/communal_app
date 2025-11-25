import 'dart:async';
import 'package:communal/backend/users_backend.dart';
import 'package:communal/models/backend_response.dart';
import 'package:communal/models/profile.dart';
import 'package:communal/presentation/common/common_alert_dialog.dart';
import 'package:communal/presentation/common/common_confirmation_dialog.dart';
import 'package:communal/presentation/common/common_list_view.dart';
import 'package:communal/presentation/community/community_specific/community_specific_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CommunityInviteController extends GetxController {
  CommunityInviteController({
    required this.communityId,
  });

  static const int pageSize = 20;

  final String communityId;
  final CommonListViewController<Profile> listViewController = CommonListViewController(pageSize: pageSize);

  final List<Profile> invitationsSent = <Profile>[];
  final RxnString selectedId = RxnString();
  final RxBool processingInvite = false.obs;

  Timer? debounceTimer;

  String query = '';

  CommunitySpecificController? communitySpecificController;

  @override
  Future<void> onInit() async {
    super.onInit();

    if (Get.isRegistered<CommunitySpecificController>()) {
      communitySpecificController = Get.find<CommunitySpecificController>();
    }

    listViewController.registerNewPageCallback(loadProfiles);
  }

  Future<List<Profile>> loadProfiles(int pageKey) async {
    final BackendResponse response = await UsersBackend.searchUsersNotInCommunity(
      communityId: communityId,
      pageKey: pageKey,
      query: query,
      pageSize: pageSize,
    );

    if (response.success) {
      List<Profile> profiles = response.payload;

      return profiles;
    }

    return [];
  }

  Future<void> searchProfiles(String string_query) async {
    query = string_query;

    debounceTimer?.cancel();

    debounceTimer = Timer(
      const Duration(milliseconds: 250),
      () async {
        query = string_query;

        await listViewController.reloadList();
      },
    );
  }

  void onSelectedIdChanged(String newId) {
    selectedId.value = newId;
  }

  Future<void> removeInvitation(BuildContext context, Profile profile) async {
    FocusScope.of(context).unfocus();

    processingInvite.value = true;

    final BackendResponse response = await UsersBackend.removeUserFromCommunity(
      communityId,
      profile.id,
    );

    if (response.success) {
      invitationsSent.removeWhere((element) => element.id == profile.id);
    }

    processingInvite.value = false;
  }

  Future<void> onSubmit(BuildContext context, Profile profile) async {
    FocusScope.of(context).unfocus();

    try {
      processingInvite.value = true;

      final BackendResponse response = await UsersBackend.inviteUserToCommunity(
        communityId,
        profile,
      );

      if (response.success) {
        invitationsSent.add(profile);

        processingInvite.value = false;
      } else {
        if (context.mounted) {
          CommonAlertDialog(
            title: response.error!,
          ).open(context);
        }
      }
    } catch (e) {
      if (context.mounted) {
        const CommonAlertDialog(
          title: 'Error in inviting user.',
        ).open(context);
      }
    }
  }

  Future<void> onRemove(BuildContext context, Profile profile) async {
    FocusScope.of(context).unfocus();
    final bool confirm = await CommonConfirmationDialog(
      title: 'Undo invitation to ${profile.username}?',
    ).open(context);

    if (confirm) {
      processingInvite.value = true;

      final BackendResponse response = await UsersBackend.removeUserFromCommunity(
        communityId,
        profile.id,
      );

      processingInvite.value = false;

      if (response.success) {
        invitationsSent.removeWhere((element) => element.id == profile.id);
      } else {
        if (context.mounted) {
          const CommonAlertDialog(
            title: 'Error in rescinding invitation.',
          ).open(context);
        }
      }
    }
  }
}
