import 'package:communal/models/community.dart';
import 'package:get/get.dart';

class CommunitySpecificController extends GetxController {
  final Community community = Get.arguments['community'];

  final RxInt selectedIndex = 0.obs;

  void onBottomNavBarIndexChanged(int value) {
    if (value == selectedIndex.value) return;

    selectedIndex.value = value;
  }
}
