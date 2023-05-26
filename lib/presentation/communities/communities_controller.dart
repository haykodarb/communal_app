import 'package:biblioteca/backend/communities_backend.dart';
import 'package:biblioteca/models/backend_response.dart';
import 'package:biblioteca/models/community.dart';
import 'package:biblioteca/routes.dart';
import 'package:get/get.dart';

class CommunitiesController extends GetxController {
  final RxList<Community> communities = <Community>[].obs;
  final RxBool loading = true.obs;

  @override
  Future<void> onInit() async {
    super.onInit();

    fetchAllCommunities();
  }

  Future<void> fetchAllCommunities() async {
    loading.value = true;
    final BackendReponse response = await CommunitiesBackend.getCommunitiesForUser();

    if (response.success) {
      communities.value = response.payload;
      communities.refresh();
    }

    loading.value = false;
  }

  Future<void> goToCreateCommunity() async {
    final bool? createdCommunity = await Get.toNamed<dynamic>(RouteNames.createCommunityPage);

    if (createdCommunity != null && createdCommunity) {
      fetchAllCommunities();
    }
  }
}
