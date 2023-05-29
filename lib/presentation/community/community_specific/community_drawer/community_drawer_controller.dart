import 'package:biblioteca/models/community.dart';
import 'package:get/get.dart';

class CommunityDrawerController extends GetxController {
  CommunityDrawerController(this.community);

  final Community community;

  final RxBool loading = true.obs;

  @override
  Future<void> onInit() async {
    super.onInit();

    loading.value = false;
  }
}
