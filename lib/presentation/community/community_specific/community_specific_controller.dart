import 'package:biblioteca/backend/communities_backend.dart';
import 'package:biblioteca/models/community.dart';
import 'package:get/get.dart';

class CommunitySpecificController extends GetxController {
  final Community community = Get.arguments['community'];

  final RxInt loadingIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    CommunitiesBackend.getBooksInCommunity(community, loadingIndex.value);
  }
}
