import 'package:communal/models/profile.dart';
import 'package:communal/presentation/common/common_circular_avatar.dart';
import 'package:communal/presentation/common/common_loading_body.dart';
import 'package:communal/presentation/common/common_search_bar.dart';
import 'package:communal/presentation/community/community_invite/community_invite_controller.dart';
import 'package:communal/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class CommunityInvitePage extends StatelessWidget {
  const CommunityInvitePage({
    super.key,
    required this.communityId,
  });

  final String communityId;

  Widget _userCard(
    BuildContext context,
    CommunityInviteController controller,
    int index,
  ) {
    final Profile profile = controller.foundProfiles[index];

    final Color selectedFg = Theme.of(context).colorScheme.onPrimary;
    final Color selectedBg = Theme.of(context).colorScheme.primary.withOpacity(0.15);

    final Color selectedBorder = Theme.of(context).colorScheme.primary;
    return InkWell(
      onTap: () => controller.onSelectedIndexChanged(index),
      child: Obx(
        () {
          final bool selected = controller.selectedIndex.value == index;

          return Container(
            height: 60,
            decoration: BoxDecoration(
              border: selected
                  ? Border.all(
                      color: selectedBorder,
                      width: 1,
                      strokeAlign: BorderSide.strokeAlignOutside,
                    )
                  : null,
              borderRadius: BorderRadius.circular(5),
              color: controller.selectedIndex.value == index ? selectedBg : null,
            ),
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                CommonCircularAvatar(
                  profile: profile,
                  radius: 20,
                ),
                const VerticalDivider(width: 5),
                Text(
                  profile.username,
                ),
                const Expanded(child: SizedBox()),
                Visibility(
                  visible: selected,
                  child: Obx(
                    () {
                      if (controller.processingInvite.value) {
                        return const CommonLoadingBody();
                      }

                      final bool alreadyInvited = controller.invitationsSent.any(
                        (e) => e.id == profile.id,
                      );

                      if (alreadyInvited) {
                        return InkWell(
                          onTap: () => controller.removeInvitation(
                            context,
                            profile,
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 5,
                              horizontal: 20,
                            ),
                            height: double.maxFinite,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surfaceContainer,
                              borderRadius: BorderRadius.circular(
                                10,
                              ),
                              border: Border.all(color: selectedBorder),
                            ),
                            child: Text(
                              'Undo',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        );
                      } else {
                        return InkWell(
                          onTap: () => controller.onSubmit(context, profile),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 5,
                              horizontal: 20,
                            ),
                            height: double.maxFinite,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: selectedBorder,
                              borderRadius: BorderRadius.circular(
                                10,
                              ),
                            ),
                            child: Text(
                              'Invitar',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: selectedFg,
                              ),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CommunityInviteController>(
      init: CommunityInviteController(communityId: communityId),
      builder: (CommunityInviteController controller) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: Responsive.isMobile(context) ? const Text('Invite user') : null,
          ),
          body: Padding(
            padding: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CommonSearchBar(
                  searchCallback: controller.onQueryChanged,
                  focusNode: FocusNode(),
                ),
                const Divider(height: 10),
                Expanded(
                  child: Card(
                    child: Obx(
                      () {
                        return CommonLoadingBody(
                          loading: controller.loading.value,
                          child: ListView.separated(
                            itemCount: controller.foundProfiles.length,
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 10,
                            ),
                            separatorBuilder: (context, index) => const Divider(
                              height: 0,
                            ),
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              return _userCard(context, controller, index);
                            },
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
}
