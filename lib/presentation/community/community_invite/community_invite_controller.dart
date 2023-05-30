import 'package:communal/backend/users_backend.dart';
import 'package:communal/models/backend_response.dart';
import 'package:communal/models/community.dart';
import 'package:communal/models/profile.dart';
import 'package:communal/presentation/common/common_confirmation_dialog.dart';
import 'package:get/get.dart';

class CommunityInviteController extends GetxController {
  final Community community = Get.arguments['community'];

  final RxList<Profile> foundProfiles = <Profile>[].obs;
  final RxnInt selectedIndex = RxnInt();
  final RxBool loading = false.obs;
  final RxBool processingInvite = false.obs;
  final RxString inviteError = ''.obs;

  final RxString query = ''.obs;

  void onQueryChanged(String value) {
    query.value = value;
  }

  void onSelectedIndexChanged(int newIndex) {
    selectedIndex.value = newIndex;
  }

  Future<void> onSubmit() async {
    Get.focusScope?.unfocus();

    if (selectedIndex.value == null) {
      inviteError.value = 'Please select a user';
      return;
    }

    final Profile selectedProfile = foundProfiles[selectedIndex.value!];

    final bool confirm = await Get.dialog(
      CommonConfirmationDialog(
        title: 'Add user ${selectedProfile.username} to ${community.name}?',
        confirmCallback: () {
          Get.back(result: true);
        },
        cancelCallback: () {
          Get.back(result: false);
        },
      ),
    );

    if (confirm) {
      processingInvite.value = true;
      inviteError.value = '';
      final BackendResponse response = await UsersBackend.inviteUserToCommunity(community, selectedProfile);
      processingInvite.value = false;

      if (!response.success) {
        inviteError.value = response.payload;
      }
    }
  }

  Future<void> onSearch() async {
    selectedIndex.value = null;
    loading.value = true;
    final BackendResponse response = await UsersBackend.searchUsers(query.value);
    loading.value = false;

    if (response.success) {
      foundProfiles.value = response.payload;
      foundProfiles.refresh();
    }
  }
}
