import 'package:biblioteca/models/community.dart';
import 'package:biblioteca/routes.dart';
import 'package:get/get.dart';

class CommunitiesController extends GetxController {
  final RxList<Community> communities = <Community>[].obs;

  void goToCreateCommunity() {
    Get.toNamed(RouteNames.createCommunityPage);
  }
}
