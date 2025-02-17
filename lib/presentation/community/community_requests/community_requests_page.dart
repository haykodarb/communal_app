import 'package:communal/backend/users_backend.dart';
import 'package:communal/models/backend_response.dart';
import 'package:communal/models/membership.dart';
import 'package:communal/models/profile.dart';
import 'package:communal/presentation/common/common_circular_avatar.dart';
import 'package:communal/presentation/common/common_confirmation_dialog.dart';
import 'package:communal/presentation/common/common_list_view.dart';
import 'package:communal/presentation/common/common_loading_body.dart';
import 'package:communal/presentation/community/community_specific/community_members/community_members_controller.dart';
import 'package:communal/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

class CommunityRequestsController extends GetxController {
  CommunityRequestsController({required this.communityId});

  static const _pageSize = 20;

  final String communityId;

  final CommonListViewController<Membership> listViewController =
      CommonListViewController<Membership>(pageSize: _pageSize);

  CommunityMembersController? communityMembersController;

  @override
  void onInit() {
    super.onInit();

    if (Get.isRegistered<CommunityMembersController>()) {
      communityMembersController = Get.find<CommunityMembersController>();
    }

    listViewController.registerNewPageCallback(loadRequests);
  }

  Future<void> respondToMembershipRequest(Membership membership, bool accept) async {
    membership.loading.value = true;
    final BackendResponse response = await UsersBackend.respondToMembershipRequest(
      membership: membership,
      accept: accept,
    );

    if (response.success) {
      if (accept) {
        communityMembersController?.listViewController.addItem(membership.member);
      }

      communityMembersController?.requestCount.value--;

      listViewController.removeItem((Membership el) => el.id == membership.id);
    }

    membership.loading.value = true;
  }

  Future<List<Membership>> loadRequests(int pageKey) async {
    final BackendResponse<List<Membership>> response = await UsersBackend.getRequestsForCommunity(
      communityId: communityId,
      pageKey: pageKey,
      pageSize: _pageSize,
    );

    if (response.success) {
      return response.payload!;
    }

    return [];
  }
}

class CommunityRequestsPage extends StatelessWidget {
  const CommunityRequestsPage({super.key, required this.communityId});
  final String communityId;

  Widget _userCard(Profile user) {
    return Builder(
      builder: (context) {
        return Card(
          child: InkWell(
            onTap: () {
              context.push(
                RouteNames.profileOtherPage.replaceFirst(
                  ':userId',
                  user.id,
                ),
              );
            },
            enableFeedback: false,
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            child: SizedBox(
              height: 60,
              child: Padding(
                padding: const EdgeInsets.only(left: 15, right: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CommonCircularAvatar(
                      profile: user,
                      radius: 20,
                      clickable: true,
                    ),
                    const VerticalDivider(width: 10),
                    Expanded(
                      child: Text(
                        user.username,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const VerticalDivider(width: 10),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: CommunityRequestsController(communityId: communityId),
      builder: (controller) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: const Text('Requests'),
          ),
          body: CommonListView<Membership>(
            controller: controller.listViewController,
            noItemsText: 'No pending requests.',
            childBuilder: (Membership membership) {
              return Obx(() {
                return CommonLoadingBody(
                  loading: membership.loading.value,
                  child: Row(
                    children: [
                      Expanded(child: _userCard(membership.member)),
                      const VerticalDivider(width: 5),
                      SizedBox(
                        width: 60,
                        child: IconButton(
                          onPressed: () async {
                            final bool confirm =
                                await const CommonConfirmationDialog(title: 'Accept membership request?').open(context);
                            if (confirm) {
                              controller.respondToMembershipRequest(membership, true);
                            }
                          },
                          style: IconButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            fixedSize: const Size.fromHeight(60),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: Icon(
                            Icons.check,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ),
                      const VerticalDivider(width: 5),
                      SizedBox(
                        width: 60,
                        child: IconButton(
                          onPressed: () async {
                            final bool confirm =
                                await const CommonConfirmationDialog(title: 'Reject membership request?').open(context);
                            if (confirm) {
                              controller.respondToMembershipRequest(membership, false);
                            }
                          },
                          style: IconButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
                            fixedSize: const Size.fromHeight(60),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(
                                color: Theme.of(context).colorScheme.primary,
                                width: 2,
                              ),
                            ),
                          ),
                          icon: Icon(
                            Icons.close,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              });
            },
          ),
        );
      },
    );
  }
}
