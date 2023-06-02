import 'package:get/get.dart';

class Profile {
  final String username;
  final String id;
  bool is_admin = false;

  final RxBool loading = false.obs;

  Profile({
    required this.username,
    required this.id,
    this.is_admin = false,
  });
}
