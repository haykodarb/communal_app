import 'package:communal/models/profile.dart';
import 'package:communal/presentation/common/common_circular_avatar.dart';
import 'package:communal/presentation/common/common_keepalive_wrapper.dart';
import 'package:communal/presentation/common/common_list_view.dart';
import 'package:communal/presentation/common/common_loading_body.dart';
import 'package:communal/presentation/common/common_search_bar.dart';
import 'package:communal/presentation/community/community_invite/community_invite_controller.dart';
import 'package:flutter/material.dart';
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
    Profile profile,
  ) {
    final Color selectedFg = Theme.of(context).colorScheme.onPrimary;
    final Color selectedBg = Theme.of(context).colorScheme.primary.withAlpha((0.15 * 255).floor());

    final Color selectedBorder = Theme.of(context).colorScheme.primary;
    return InkWell(
      onTap: () => controller.onSelectedIdChanged(profile.id),
      child: Obx(
        () {
          final bool selected = controller.selectedId.value == profile.id;

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
              color: selected ? selectedBg : null,
            ),
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                CommonKeepaliveWrapper(
                  child: CommonCircularAvatar(
                    profile: profile,
                    radius: 20,
                  ),
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
                                5,
                              ),
                              border: Border.all(color: selectedBorder),
                            ),
                            child: Text(
                              'Undo'.tr,
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
                                5,
                              ),
                            ),
                            child: Text(
                              'Invite'.tr,
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
            title: Text('Invite user'.tr),
          ),
          body: Padding(
            padding: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CommonSearchBar(
                  searchCallback: controller.searchProfiles,
                  focusNode: FocusNode(),
                ),
                const Divider(height: 10),
                Expanded(
                  child: Card(
                    child: CommonListView<Profile>(
                      controller: controller.listViewController,
                      childBuilder: (Profile profile) {
                        return CommonKeepaliveWrapper(child: _userCard(context, controller, profile));
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
