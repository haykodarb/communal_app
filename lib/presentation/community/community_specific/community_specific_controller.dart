import 'package:biblioteca/backend/users_backend.dart';
import 'package:biblioteca/models/backend_response.dart';
import 'package:biblioteca/models/community.dart';
import 'package:biblioteca/models/profile.dart';
import 'package:get/get.dart';

class CommunitySpecificController extends GetxController {
  final Community community = Get.arguments['community'];

  final RxList<Profile> usersInCommunity = <Profile>[].obs;

  final RxInt loadingIndex = 0.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    final BackendReponse response = await UsersBackend.getUsersInCommunity(community);

    print(response.payload);

    if (response.success) {
      usersInCommunity.value = response.payload;
      usersInCommunity.refresh();
    }
  }
}
