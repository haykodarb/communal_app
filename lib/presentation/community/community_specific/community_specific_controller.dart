import 'package:communal/backend/books_backend.dart';
import 'package:communal/models/backend_response.dart';
import 'package:communal/models/book.dart';
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
