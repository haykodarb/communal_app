import 'package:communal/models/community.dart';
import 'package:communal/presentation/community/community_specific/community_books/community_books_controller.dart';
import 'package:communal/presentation/community/community_specific/community_discussions/community_discussions_controller.dart';
import 'package:communal/presentation/community/community_specific/community_members/community_members_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CommunitySpecificController extends GetxController with GetTickerProviderStateMixin {
  final Community community = Get.arguments['community'];

  final CommunityMembersController membersController = CommunityMembersController();
  final CommunityDiscussionsController discussionsController = CommunityDiscussionsController();
  final CommunityBooksController booksController = CommunityBooksController();

  final ScrollController scrollController = ScrollController();

  late AnimationController bottomBarAnimationController;
  late Animation<Offset> bottomBarAnimation;
  late Animation<double> floatingActionButtonAnimation;

  final RxInt selectedIndex = 0.obs;
  final RxBool showBottomNavBar = true.obs;

  double maxOffset = 0;

  @override
  void onInit() {
    bottomBarAnimationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    floatingActionButtonAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: bottomBarAnimationController, curve: Curves.linear),
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
    super.onInit();
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  void onBottomNavBarIndexChanged(int value) {
    if (value == selectedIndex.value) return;

    selectedIndex.value = value;
  }
}
