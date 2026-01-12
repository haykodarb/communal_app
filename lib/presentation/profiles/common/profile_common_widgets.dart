import 'package:atlas_icons/atlas_icons.dart';
import 'package:communal/models/loan.dart';
import 'package:communal/models/profile.dart';
import 'package:communal/presentation/common/common_book_cover.dart';
import 'package:communal/presentation/common/common_circular_avatar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ProfileCommonWidgets {
  static Widget avatarRow({
    required Profile profile,
    required IconData icon,
    required VoidCallback onIconPressed,
    bool isOwnProfile = false,
  }) {
    return Builder(
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
          child: Row(
            children: [
              CommonCircularAvatar(
                profile: profile,
                radius: 37.5,
              ),
              const VerticalDivider(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: isOwnProfile ? BoxFit.scaleDown : BoxFit.fitWidth,
                      child: Text(
                        isOwnProfile && profile.username.isEmpty
                            ? ' '
                            : profile.username,
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
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  child: Row(
                    children: [
                      Icon(Atlas.user_plus),
                      Text('Add friend'),
                    ],
                  ),
                ),
              ),
              IconButton(
                onPressed: onIconPressed,
                iconSize: 24,
                icon: Icon(icon),
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
          padding: const EdgeInsets.symmetric(horizontal: 30),
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
            horizontal: 30,
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
    bool useTranslations = false,
  }) {
    return Builder(
      builder: (BuildContext context) {
        final Color selectedBg = Theme.of(context).colorScheme.primary;
        final Color selectedFg = Theme.of(context).colorScheme.onPrimary;
        final Color unselectedBg =
            Theme.of(context).colorScheme.surfaceContainer;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                            useTranslations ? 'Books'.tr : 'Books',
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
                            useTranslations ? 'Reviews'.tr : 'Reviews',
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                        height: onTap != null ? 120 : 960,
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
