import 'package:communal/backend/communities_backend.dart';
import 'package:communal/backend/user_preferences.dart';
import 'package:communal/models/backend_response.dart';
import 'package:communal/models/community.dart';
import 'package:communal/presentation/common/common_list_view.dart';
import 'package:communal/routes.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

class CommunityListController extends GetxController {
  static const int pageSize = 20;
  final CommonListViewController<Community> listViewController = CommonListViewController(pageSize: pageSize);
  final RxBool loading = true.obs;

  @override
  void onInit() {
    super.onInit();
    listViewController.registerNewPageCallback(loadCommunities);
  }

  Future<List<Community>> loadCommunities(int pageKey) async {
    final BackendResponse response = await CommunitiesBackend.getCommunitiesForCurrentUser(
      pageKey: pageKey,
      pageSize: pageSize,
    );

    if (response.success) {
      List<String> pinned_communities = await UserPreferences.getPinnedCommunitiesIds();

      List<Community> resultCommunities = response.payload;
      List<Community> sortedCommunities = <Community>[];

      for (int i = 0; i < resultCommunities.length; i++) {
        if (pinned_communities.any((element) => element == resultCommunities[i].id)) {
          resultCommunities[i].pinned.value = true;
          sortedCommunities.insert(0, resultCommunities[i]);
        } else {
          sortedCommunities.add(resultCommunities[i]);
        }
      }
      return sortedCommunities;
    }

    return [];
  }

  Future<void> goToCommunityCreate(BuildContext context) async {
    await context.push(
      RouteNames.communityListPage + RouteNames.communityCreatePage,
    );
  }

  Future<void> goToCommunitySpecific(Community community, BuildContext context) async {
    context.push('${RouteNames.communityListPage}/${community.id}');
  }

  Future<void> toggleCommunityPinnedValue(Community community) async {
    community.pinned.value = !community.pinned.value;

    UserPreferences.setPinnedCommunityValue(
      community.id,
      community.pinned.value,
    );

    if (community.pinned.value) {
      int index = listViewController.itemList.indexWhere((el) => el.id == community.id);

      if (index > 0) {
        listViewController.itemList.removeAt(index);
        listViewController.itemList.insert(0, community);
        listViewController.itemList.refresh();
      }
    }
  }
}
