import 'package:biblioteca/backend/communities_backend.dart';
import 'package:biblioteca/backend/users_backend.dart';
import 'package:biblioteca/models/backend_response.dart';
import 'package:biblioteca/models/community.dart';
import 'package:biblioteca/models/profile.dart';
import 'package:get/get.dart';

class CommunityDrawerController extends GetxController {
  CommunityDrawerController(this.community);

  final Community community;

  bool isUserAdmin = false;

  final RxBool loading = true.obs;

  final RxList<Profile> usersInCommunity = <Profile>[].obs;

  final RxInt loadingIndex = 0.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    isUserAdmin = await CommunitiesBackend.isUserAdmin(community);

    loading.value = false;
  }
}
