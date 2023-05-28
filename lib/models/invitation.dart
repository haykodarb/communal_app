import 'package:get/get.dart';

class Invitation {
  final String id;
  final String communityId;
  final String communityName;
  final String communityDescription;
  final String userId;

  final RxBool loading = false.obs;

  Invitation({
    required this.id,
    required this.communityId,
    required this.communityName,
    required this.communityDescription,
    required this.userId,
  });
}
