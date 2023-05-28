import 'package:biblioteca/backend/users_backend.dart';
import 'package:biblioteca/models/backend_response.dart';
import 'package:biblioteca/models/invitation.dart';
import 'package:get/get.dart';

class InvitationsController extends GetxController {
  final RxList<Invitation> invitationsList = <Invitation>[].obs;

  final RxBool loading = true.obs;

  @override
  void onInit() {
    super.onInit();

    loadInvitations();
  }

  Future<void> acceptInvitation(Invitation invitation) async {
    invitation.loading.value = true;
    final BackendReponse response = await UsersBackend.acceptInvitation(invitation);

    if (response.success) {
      invitationsList.remove(invitation);
    }

    invitation.loading.value = false;
  }

  Future<void> loadInvitations() async {
    loading.value = true;

    final BackendReponse response = await UsersBackend.getInvitationsForUser();

    if (response.success) {
      invitationsList.value = response.payload;
    } else {
      invitationsList.clear();
    }

    loading.value = false;
  }
}
