import 'dart:async';
import 'package:communal/backend/communities_backend.dart';
import 'package:communal/backend/users_backend.dart';
import 'package:communal/models/backend_response.dart';
import 'package:communal/models/community.dart';
import 'package:communal/models/profile.dart';
import 'package:communal/presentation/common/common_confirmation_dialog.dart';
import 'package:communal/presentation/community/community_specific/community_specific_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CommunityInviteController extends GetxController {
  CommunityInviteController({
    required this.communityId,
  });

  final String communityId;

  Community? community;

  final RxList<Profile> foundProfiles = <Profile>[].obs;
  final List<Profile> invitationsSent = <Profile>[];
  final RxnInt selectedIndex = RxnInt();
  final RxBool loading = false.obs;
  final RxBool processingInvite = false.obs;
  final RxString inviteError = ''.obs;

  Timer? debounceTimer;

  final RxString query = ''.obs;

  CommunitySpecificController? communitySpecificController;

  @override
  Future<void> onInit() async {
    super.onInit();

    if (Get.isRegistered<CommunitySpecificController>()) {
      communitySpecificController = Get.find<CommunitySpecificController>();
    }

    community ??= communitySpecificController?.community;

    if (community == null) {
      final BackendResponse response = await CommunitiesBackend.getCommunityById(communityId);

      if (response.success) {
        community = response.payload;
      }
    }

    onQueryChanged('');
  }

  void onQueryChanged(String value) {
    query.value = value;

    debounceTimer?.cancel();

    debounceTimer = Timer(
      const Duration(milliseconds: 500),
      () {
        onSearch();
      },
    );
  }

  void onSelectedIndexChanged(int newIndex) {
    selectedIndex.value = newIndex;
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

    processingInvite.value = true;
    inviteError.value = '';

    final BackendResponse response = await UsersBackend.inviteUserToCommunity(
      communityId,
      profile,
    );

    if (response.success) {
      inviteError.value = 'User invite sent.';
      invitationsSent.add(profile);

      processingInvite.value = false;
    } else {
      inviteError.value = response.payload;
    }
  }

  Future<void> onRemove(BuildContext context, Profile profile) async {
    FocusScope.of(context).unfocus();
    final bool confirm = await CommonConfirmationDialog(
      title: 'Undo invitation to ${profile.username}?',
    ).open(context);

    if (confirm) {
      processingInvite.value = true;
      inviteError.value = '';

      final BackendResponse response = await UsersBackend.removeUserFromCommunity(
        communityId,
        profile.id,
      );

      processingInvite.value = false;

      if (response.success) {
        inviteError.value = 'Invitation rescinded.';
        invitationsSent.removeWhere((element) => element.id == profile.id);
      } else {
        inviteError.value = 'Could not rescind invitation.';
      }
    }
  }

  Future<void> onSearch() async {
    selectedIndex.value = null;
    loading.value = true;
    final BackendResponse response = await UsersBackend.searchUsersNotInCommunity(
      communityId: communityId,
      query: query.value,
      pageKey: 0,
      pageSize: 20,
    );
    loading.value = false;

    if (response.success) {
      foundProfiles.value = response.payload;
      foundProfiles.refresh();
    }
  }
}
