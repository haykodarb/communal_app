import 'package:communal/backend/communities_backend.dart';
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
    final BackendResponse response = await CommunitiesBackend.getCommunitiesForUser();

    if (response.success) {
      communities.value = response.payload;
      communities.refresh();
    } else {
      communities.clear();
    }

    loading.value = false;
  }

  Future<void> goToCommunityCreate() async {
    final bool? createdCommunity = await Get.toNamed<dynamic>(RouteNames.communityCreatePage);

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
}
