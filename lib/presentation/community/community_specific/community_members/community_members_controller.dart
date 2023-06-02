import 'package:communal/backend/users_backend.dart';
import 'package:communal/models/backend_response.dart';
import 'package:communal/models/community.dart';
import 'package:communal/models/profile.dart';
import 'package:get/get.dart';

class CommunityMembersController extends GetxController {
  final Community community = Get.arguments['community'];

  final RxList<Profile> listOfMembers = <Profile>[].obs;

  final RxBool loading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadUsers();
  }

  Future<void> removeUser(Profile user) async {
    user.loading.value = true;

    final BackendResponse response = await UsersBackend.removeUserFromCommunity(community, user);

    if (response.success) {
      listOfMembers.remove(user);
      user.loading.value = false;
      print(response.payload);
    }
  }

  Future<void> changeUserAdmin(Profile user, bool shouldBeAdmin) async {
    user.loading.value = true;

    final BackendResponse response = await UsersBackend.makeUserAdminOfCommunity(community, user, shouldBeAdmin);

    if (response.success) {
      user.is_admin = shouldBeAdmin;
      user.loading.value = false;
    }
  }

  Future<void> loadUsers() async {
    loading.value = true;

    final BackendResponse<List<Profile>> response = await UsersBackend.getUsersInCommunity(community);

    if (response.success) {
      listOfMembers.value = response.payload;
    }

    loading.value = false;
  }
}
