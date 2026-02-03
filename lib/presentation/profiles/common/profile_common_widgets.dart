import 'package:atlas_icons/atlas_icons.dart';
import 'package:communal/backend/friendships_backend.dart';
import 'package:communal/models/backend_response.dart';
import 'package:communal/models/friendship.dart';
import 'package:communal/models/loan.dart';
import 'package:communal/models/profile.dart';
import 'package:communal/presentation/common/common_book_cover.dart';
import 'package:communal/presentation/common/common_button.dart';
import 'package:communal/presentation/common/common_circular_avatar.dart';
import 'package:communal/presentation/common/common_confirmation_dialog.dart';
import 'package:communal/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class ProfileCommonWidgets {
  static Widget _editProfileButton() {
    return CommonButton(
      type: CommonButtonType.outlined,
      expand: false,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Atlas.pencil_bold,
            size: 16,
          ),
          const VerticalDivider(width: 4),
          Text(
            'Edit profile'.tr,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      onPressed: (BuildContext context) async {
        context.push(
          RouteNames.profileOwnPage + RouteNames.profileOwnEditPage,
        );
      },
    );
  }

  static Widget _removeFriendButton(Profile profile) {
    final bool isPending = profile.friendship?.isAccepted ?? false;

    return CommonButton(
      type: CommonButtonType.outlined,
      expand: false,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12),
      ),
      child: Visibility(
        visible: isPending,
        replacement: Row(
          children: [
            const Icon(
              Atlas.user_minus_bold,
              size: 16,
            ),
            const VerticalDivider(width: 4),
            Text(
              'Pending'.tr,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Atlas.user_check_bold,
              size: 16,
            ),
            const VerticalDivider(width: 4),
            Text(
              'Friends'.tr,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      onPressed: (BuildContext context) async {
        final String text = isPending
            ? 'Remove ${profile.username} as friend?'
            : 'Withdraw friend request?';

        final bool confirm = await CommonConfirmationDialog(
          title: text,
        ).open(context);

        if (confirm) {
          FriendshipsBackend.deleteFriendship(profile.id);
        }
      },
    );
  }

  static Widget _addFriendButton(Profile profile) {
    return CommonButton(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12),
      ),
      expand: false,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Atlas.user_plus_bold,
            size: 18,
          ),
          const VerticalDivider(width: 4),
          Text(
            'Add friend'.tr,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      onPressed: (BuildContext context) async {
        final bool confirm = await CommonConfirmationDialog(
          title: 'Add ${profile.username} as friend?',
        ).open(context);

        if (confirm) {
          FriendshipsBackend.sendFriendRequest(profile.id);
        }
      },
    );
  }

  static Widget _messageUserButton(Profile profile) {
    return AspectRatio(
      aspectRatio: 1,
      child: CommonButton(
        type: profile.friendship != null
            ? CommonButtonType.filledIcon
            : CommonButtonType.outlinedIcon,
        expand: false,
        onPressed: (BuildContext context) {
          context.push(
            '${RouteNames.messagesPage}/${profile.id}',
          );
        },
        child: const Icon(
          Atlas.comment_dots_bold,
          size: 16,
        ),
      ),
    );
  }

  static Widget avatarRow({
    required Profile profile,
    required IconData icon,
    required VoidCallback onIconPressed,
    bool isOwnProfile = false,
  }) {
    const int avatarHeight = 105;

    return Builder(
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          height: avatarHeight + 20,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CommonCircularAvatar(
                profile: profile,
                radius: avatarHeight / 2,
              ),
              const VerticalDivider(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FittedBox(
                          fit:
                              isOwnProfile ? BoxFit.scaleDown : BoxFit.fitWidth,
                          child: Text(
                            profile.username,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 20,
                            ),
                          ),
                        ),
                        Visibility(
                          visible: profile.email != null,
                          child: FittedBox(
                            fit: BoxFit.fitWidth,
                            child: Text(
                              profile.email ?? '',
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Visibility(
                      visible: !profile.isCurrentUser,
                      replacement: SizedBox(
                        height: 35,
                        child: Row(
                          children: [
                            _editProfileButton(),
                            const Expanded(child: SizedBox()),
                          ],
                        ),
                      ),
                      child: SizedBox(
                        height: 35,
                        child: Row(
                          children: [
                            Visibility(
                              visible: profile.friendship == null,
                              replacement: _removeFriendButton(profile),
                              child: _addFriendButton(profile),
                            ),
                            const VerticalDivider(width: 8),
                            _messageUserButton(profile),
                            const Expanded(child: SizedBox()),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget bio(Profile profile) {
    return Builder(
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'About me'.tr,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Divider(height: 5),
              Text(
                profile.bio ?? '',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget loanCount() {
    return Builder(
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 10,
            horizontal: 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '56 items borrowed',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '32 items lent',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget tabBar({
    required RxInt currentTabIndex,
    required Function(int) onTabTapped,
  }) {
    return Builder(
      builder: (BuildContext context) {
        final Color selectedBg = Theme.of(context).colorScheme.primary;
        final Color selectedFg = Theme.of(context).colorScheme.onPrimary;
        final Color unselectedBg =
            Theme.of(context).colorScheme.surfaceContainer;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(10),
            height: 70,
            width: double.maxFinite,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(50),
            ),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => onTabTapped(0),
                    child: Obx(
                      () {
                        return Container(
                          decoration: BoxDecoration(
                            color: currentTabIndex.value == 0
                                ? selectedBg
                                : unselectedBg,
                            borderRadius: BorderRadius.circular(40),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Books'.tr,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: currentTabIndex.value == 0
                                  ? selectedFg
                                  : selectedBg,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () => onTabTapped(1),
                    child: Obx(
                      () {
                        return Container(
                          decoration: BoxDecoration(
                            color: currentTabIndex.value == 1
                                ? selectedBg
                                : unselectedBg,
                            borderRadius: BorderRadius.circular(40),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Reviews'.tr,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: currentTabIndex.value == 1
                                  ? selectedFg
                                  : selectedBg,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Widget reviewCard({
    required Loan loan,
    VoidCallback? onTap,
  }) {
    return Builder(
      builder: (context) {
        final card = Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loan.book.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              height: 1.2,
                            ),
                          ),
                          const Divider(height: 5),
                          Text(
                            loan.book.author,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              height: 1.2,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                          const Divider(height: 5),
                          Text(
                            '${DateFormat('MMM d, y', Get.locale?.languageCode).format(loan.latest_date!).capitalizeFirst}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.italic,
                              height: 1.2,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 100,
                      child: CommonBookCover(
                        loan.book,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 20),
                Text(
                  loan.review!,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        );

        if (onTap != null) {
          return InkWell(
            onTap: onTap,
            child: card,
          );
        }

        return card;
      },
    );
  }
}
