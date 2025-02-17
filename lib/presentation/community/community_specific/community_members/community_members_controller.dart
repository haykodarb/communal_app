import 'dart:async';

import 'package:communal/backend/users_backend.dart';
import 'package:communal/models/backend_response.dart';
import 'package:communal/models/profile.dart';
import 'package:communal/presentation/common/common_alert_dialog.dart';
import 'package:communal/presentation/common/common_list_view.dart';
import 'package:communal/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

class CommunityMembersController extends GetxController {
  static const int pageSize = 20;

  CommunityMembersController({required this.communityId});

  final String communityId;

  final CommonListViewController<Profile> listViewController = CommonListViewController(pageSize: pageSize);

  String query = '';

  Timer? debounceTimer;

  final RxInt requestCount = 0.obs;

  @override
  Future<void> onInit() async {
    super.onInit();

    final BackendResponse<int> response = await UsersBackend.getRequestCountForCommunity(communityId: communityId);

    if (response.success) {
      requestCount.value = response.payload!;
    }

    listViewController.registerNewPageCallback(loadUsers);
  }

  void addUser(BuildContext context) {
    context.push('${RouteNames.communityListPage}/$communityId${RouteNames.communityInvitePage}');
  }

  Future<void> removeUser(Profile user, BuildContext context) async {
    user.loading.value = true;

    final BackendResponse response = await UsersBackend.removeUserFromCommunity(communityId, user.id);

    if (response.success) {
      listViewController.itemList.removeWhere((element) => element.id == user.id);
      listViewController.refresh();
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

  void reloadList() {
    debounceTimer?.cancel();

    debounceTimer = Timer(
      const Duration(milliseconds: 500),
      listViewController.reloadList,
    );
  }

  Future<List<Profile>> loadUsers(int pageKey) async {
    final BackendResponse<List<Profile>> response = await UsersBackend.getUsersInCommunity(
      query: query,
      communityId: communityId,
      pageKey: pageKey,
      pageSize: pageSize,
    );

    if (response.success) {
      return response.payload!;
    }

    return [];
  }
}
