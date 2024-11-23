import 'package:communal/backend/communities_backend.dart';
import 'package:communal/models/backend_response.dart';
import 'package:communal/models/community.dart';
import 'package:communal/presentation/community/community_list_controller.dart';
import 'package:communal/presentation/community/community_specific/community_books/community_books_controller.dart';
import 'package:communal/presentation/community/community_specific/community_discussions/community_discussions_controller.dart';
import 'package:communal/presentation/community/community_specific/community_members/community_members_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CommunitySpecificController extends GetxController
    with GetTickerProviderStateMixin {
  CommunitySpecificController({required this.communityId});
  final String communityId;

  RxBool loading = false.obs;
  late Community community;
  CommunityListController? communityListController;

  final ScrollController scrollController = ScrollController();

  late AnimationController bottomBarAnimationController;
  late Animation<Offset> bottomBarAnimation;
  late Animation<double> floatingActionButtonAnimation;

  final RxInt selectedIndex = 0.obs;
  final RxBool showBottomNavBar = true.obs;

  late CommunityMembersController membersController =
      CommunityMembersController(
    communityId: communityId,
  );

  late CommunityDiscussionsController discussionsController =
      CommunityDiscussionsController(
    communityId: communityId,
  );

  late CommunityBooksController booksController = CommunityBooksController(
    communityId: communityId,
  );

  double maxOffset = 0;

  @override
  Future<void> onInit() async {
    super.onInit();
    loading.value = true;
    if (Get.isRegistered<CommunityListController>()) {
      communityListController = Get.find<CommunityListController>();
    }

    Get.lazyPut(() => CommunityBooksController(communityId: communityId));
    Get.lazyPut(() => CommunityMembersController(communityId: communityId));
    Get.lazyPut(() => CommunityDiscussionsController(communityId: communityId));

    Community? tmp = communityListController?.communities.firstWhereOrNull(
      (element) => element.id == communityId,
    );

    if (tmp != null) {
      community = tmp;
    } else {
      final BackendResponse response =
          await CommunitiesBackend.getCommunityById(
        communityId,
      );

      if (response.success) {
        community = response.payload;
      }
    }

    bottomBarAnimationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    floatingActionButtonAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: bottomBarAnimationController, curve: Curves.linear),
    );

    bottomBarAnimation = Tween<Offset>(
      begin: const Offset(0, 2),
      end: const Offset(0, 0),
    ).animate(
      CurvedAnimation(
        parent: bottomBarAnimationController,
        curve: Curves.linear,
      ),
    );

    bottomBarAnimationController.forward();

    scrollController.addListener(
      () {
        if (scrollController.offset > maxOffset) {
          maxOffset = scrollController.offset;
        }

        if (scrollController.offset >= maxOffset * 0.9) {
          if (bottomBarAnimation.isCompleted) {
            bottomBarAnimationController.reverse();
          }
        } else if (scrollController.offset <= maxOffset * 0.1) {
          if (bottomBarAnimation.isDismissed) {
            bottomBarAnimationController.forward();
          }
        }
      },
    );

    loading.value = false;
  }

  @override
  void onClose() {
    scrollController.dispose();
    bottomBarAnimationController.dispose();

    super.onClose();
  }

  void onBottomNavBarIndexChanged(int value) {
    if (value == selectedIndex.value) return;

    selectedIndex.value = value;
  }
}
