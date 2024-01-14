import 'package:communal/backend/users_backend.dart';
import 'package:communal/models/backend_response.dart';
import 'package:communal/models/profile.dart';
import 'package:get/get.dart';

class ProfileOtherController extends GetxController {
  final RxBool loading = true.obs;
  final Profile inheritedProfile = Get.arguments['user'];
  final Rx<Profile> profile = Profile.empty().obs;

  @override
  Future<void> onInit() async {
    super.onInit();

    final BackendResponse response = await UsersBackend.getUserProfile(inheritedProfile.id);

    if (response.success) {
      profile.value = response.payload;
    }

    loading.value = false;
  }
}
