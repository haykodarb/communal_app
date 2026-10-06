import 'dart:async';

import 'package:communal/backend/friendships_backend.dart';
import 'package:communal/backend/realtime_backend.dart';
import 'package:communal/models/backend_response.dart';
import 'package:communal/models/friendship.dart';
import 'package:communal/models/realtime_message.dart';
import 'package:communal/presentation/common/common_alert_dialog.dart';
import 'package:communal/presentation/common/common_confirmation_dialog.dart';
import 'package:communal/presentation/common/common_drawer/common_drawer_controller.dart';
import 'package:communal/presentation/common/common_list_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Friends / Received / Sent tabs over the friendships table.
class FriendshipsController extends GetxController {
  static const int pageSize = 30;

  final RxInt currentTabIndex = 0.obs;
  final ScrollController scrollController = ScrollController();

  final CommonListViewController<Friendship> friendsController =
      CommonListViewController(pageSize: pageSize);
  final CommonListViewController<Friendship> receivedController =
      CommonListViewController(pageSize: pageSize);
  final CommonListViewController<Friendship> sentController =
      CommonListViewController(pageSize: pageSize);

  StreamSubscription? realtimeSubscription;

  List<CommonListViewController<Friendship>> get _lists =>
      [friendsController, receivedController, sentController];

  CommonListViewController<Friendship> get currentList =>
      _lists[currentTabIndex.value];

  @override
  void onInit() {
    super.onInit();

    friendsController.registerNewPageCallback(
      (pageKey) => _load(FriendshipsBackend.getFriends(
        pageKey: pageKey,
        pageSize: pageSize,
      )),
    );
    receivedController.registerNewPageCallback(
      (pageKey) => _load(FriendshipsBackend.getPendingRequests(
        pageKey: pageKey,
        pageSize: pageSize,
      )),
    );
    sentController.registerNewPageCallback(
      (pageKey) => _load(FriendshipsBackend.getSentRequests(
        pageKey: pageKey,
        pageSize: pageSize,
      )),
    );

    // New or withdrawn requests arrive as notification changes (friendships
    // aren't in the realtime publication).
    realtimeSubscription = RealtimeBackend.streamController.stream.listen(
      (RealtimeMessage realtime) {
        if (realtime.table != 'notifications') return;
        currentList.reloadList();
      },
    );
  }

  @override
  void onClose() {
    realtimeSubscription?.cancel();
    super.onClose();
  }

  Future<List<Friendship>> _load(
    Future<BackendResponse<List<Friendship>>> request,
  ) async {
    final BackendResponse<List<Friendship>> response = await request;
    return response.success ? response.payload ?? [] : [];
  }

  void onTabTapped(int index) {
    currentTabIndex.value = index;
    currentList.reloadList();
  }

  Future<void> _run(
    Friendship friendship,
    String title,
    Future<BackendResponse> Function() action,
    BuildContext context,
  ) async {
    final bool confirmed =
        await CommonConfirmationDialog(title: title).open(context);
    if (!confirmed) return;

    friendship.loading.value = true;
    final CommonListViewController<Friendship> list = currentList;
    final BackendResponse response = await action();
    friendship.loading.value = false;

    if (response.success) {
      list.removeItem((element) => element.id == friendship.id);
      Get.find<CommonDrawerController>().getFriendRequests();
    } else if (context.mounted) {
      CommonAlertDialog(title: response.error ?? 'Server error.'.tr)
          .open(context);
    }
  }

  void accept(Friendship friendship, BuildContext context) => _run(
        friendship,
        'Accept this request?'.tr,
        () async {
          final BackendResponse response =
              await FriendshipsBackend.respondToFriendRequest(
            friendshipId: friendship.id,
            accept: true,
          );
          friendsController.reloadList();
          return response;
        },
        context,
      );

  // Rejecting deletes the request so it can be sent again later.
  void reject(Friendship friendship, BuildContext context) => _run(
        friendship,
        'Reject this request?'.tr,
        () => FriendshipsBackend.deleteFriendship(friendship.id),
        context,
      );

  void withdraw(Friendship friendship, BuildContext context) => _run(
        friendship,
        'Withdraw friend request?'.tr,
        () => FriendshipsBackend.deleteFriendship(friendship.id),
        context,
      );

  void remove(Friendship friendship, BuildContext context) => _run(
        friendship,
        'Remove {name} as friend?'
            .tr
            .replaceFirst('{name}', friendship.otherUser.username),
        () => FriendshipsBackend.deleteFriendship(friendship.id),
        context,
      );
}
