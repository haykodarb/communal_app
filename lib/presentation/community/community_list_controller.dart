import 'package:communal/backend/communities_backend.dart';
import 'package:communal/backend/user_preferences.dart';
import 'package:communal/models/backend_response.dart';
import 'package:communal/models/community.dart';
import 'package:communal/routes.dart';
import 'package:get/get.dart';

class CommunityListController extends GetxController {
  final RxList<Community> communities = <Community>[].obs;
  final RxBool loading = true.obs;

  @override
  void onReady() {
    fetchAllCommunities();

    super.onReady();
  }

  Future<void> fetchAllCommunities() async {
    loading.value = true;
    final BackendResponse response =
        await CommunitiesBackend.getCommunitiesForUser();

    if (response.success) {
      List<String> pinned_communities =
          await UserPreferences.getPinnedCommunitiesIds();

      List<Community> resultCommunities = response.payload;
      List<Community> sortedCommunities = <Community>[];

      for (int i = 0; i < resultCommunities.length; i++) {
        if (pinned_communities
            .any((element) => element == resultCommunities[i].id)) {
          resultCommunities[i].pinned.value = true;
          sortedCommunities.insert(0, resultCommunities[i]);
        } else {
          sortedCommunities.add(resultCommunities[i]);
        }
      }
      communities.value = sortedCommunities;
      communities.refresh();
    } else {
      communities.clear();
    }

    loading.value = false;
  }

  Future<void> goToCommunityCreate() async {
    final bool? createdCommunity =
        await Get.toNamed<dynamic>(RouteNames.communityCreatePage);

    if (createdCommunity != null && createdCommunity) {
      fetchAllCommunities();
    }
  }

  Future<void> goToCommunitySpecific(Community community) async {
    Get.toNamed(
      RouteNames.communitySpecificPage,
      arguments: {
        'community': community,
      },
    )?.then(
      (value) => fetchAllCommunities(),
    );
  }

  Future<void> toggleCommunityPinnedValue(Community community) async {
    community.pinned.value = !community.pinned.value;

    UserPreferences.setPinnedCommunityValue(
      community.id,
      community.pinned.value,
    );
  }
}
