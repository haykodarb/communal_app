import 'package:communal/backend/users_backend.dart';
import 'package:communal/models/backend_response.dart';
import 'package:communal/models/profile.dart';
import 'package:communal/presentation/common/common_alert_dialog.dart';
import 'package:communal/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

class CommunityMembersController extends GetxController {
  CommunityMembersController({required this.communityId});

  final RxList<Profile> listOfMembers = <Profile>[].obs;
  final RxBool loading = true.obs;
  final String communityId;

  @override
  Future<void> onInit() async {
    super.onInit();

    loadUsers();
  }

  void addUser(BuildContext context) {
    context.push(
        '${RouteNames.communityListPage}/$communityId${RouteNames.communityInvitePage}');
  }

  Future<void> removeUser(Profile user, BuildContext context) async {
    user.loading.value = true;

    final BackendResponse response =
        await UsersBackend.removeUserFromCommunity(communityId, user.id);

    if (response.success) {
      listOfMembers.remove(user);
    } else {
      if (context.mounted) {
        CommonAlertDialog(title: response.payload).open(context);
      }
    }

    user.loading.value = false;
  }

  Future<void> changeUserAdmin(
    Profile user,
    bool shouldBeAdmin,
    BuildContext context,
  ) async {
    user.loading.value = true;

    final BackendResponse response = await UsersBackend.changeUserAdminStatus(
      communityId,
      user,
      shouldBeAdmin,
    );

    if (response.success) {
      user.is_admin = shouldBeAdmin;
    } else {
      if (context.mounted) {
        CommonAlertDialog(title: response.payload).open(context);
      }
    }

    user.loading.value = false;
  }

  Future<void> loadUsers() async {
    loading.value = true;

    final BackendResponse<List<Profile>> response =
        await UsersBackend.getUsersInCommunity(communityId);

    if (response.success) {
      listOfMembers.value = response.payload;
    }

    loading.value = false;
  }
}
