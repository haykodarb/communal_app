import 'package:communal/models/community.dart';
import 'package:get/get.dart';

class Invitation {
  final String id;
  final String userId;
  final Community community;

  final RxBool loading = false.obs;

  Invitation({
    required this.id,
    required this.community,
    required this.userId,
  });
}
