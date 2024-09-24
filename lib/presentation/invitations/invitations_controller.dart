import 'package:communal/backend/users_backend.dart';
import 'package:communal/models/backend_response.dart';
import 'package:communal/models/membership.dart';
import 'package:get/get.dart';

class InvitationsController extends GetxController {
  final RxList<Membership> invitationsList = <Membership>[].obs;

  final RxBool loading = true.obs;

  @override
  void onInit() {
    super.onInit();

    loadInvitations();
  }

  Future<void> respondToInvitation(Membership invitation, bool accept) async {
    invitation.loading.value = true;

    final BackendResponse response = await UsersBackend.respondToInvitation(invitation.id, accept);

    if (response.success) {
      invitationsList.remove(invitation);
    }

    invitation.loading.value = false;
  }

  Future<void> loadInvitations() async {
    loading.value = true;

    final BackendResponse response = await UsersBackend.getInvitationsForUser();

    if (response.success) {
      invitationsList.value = response.payload;
    } else {
      invitationsList.clear();
    }

    loading.value = false;
  }
}
