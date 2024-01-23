import 'dart:async';
import 'package:communal/backend/tools_backend.dart';
import 'package:communal/models/backend_response.dart';
import 'package:communal/models/tool.dart';
import 'package:communal/models/community.dart';
import 'package:get/get.dart';

class CommunityToolsController extends GetxController {
  final Community community = Get.arguments['community'];

  final RxList<Tool> toolsLoaded = <Tool>[].obs;

  final RxBool loadingMore = false.obs;
  final RxBool firstLoad = true.obs;

  int loadingIndex = 0;

  Timer? searchDebounceTimer;
  Timer? loadMoreDebounceTimer;

  @override
  Future<void> onInit() async {
    await searchTools('');

    super.onInit();
  }

  Future<void> reloadPage() async {
    loadingIndex = 0;

    firstLoad.value = true;
    await searchTools('');
    firstLoad.value = false;
  }

  Future<void> searchTools(String string_query) async {
    searchDebounceTimer?.cancel();

    searchDebounceTimer = Timer(
      const Duration(milliseconds: 500),
      () async {
        firstLoad.value = true;

        final BackendResponse response = await ToolsBackend.getToolsInCommunity(community, 0, string_query);

        if (response.success) {
          toolsLoaded.value = response.payload;
          toolsLoaded.refresh();
          loadingIndex++;
        }

        firstLoad.value = false;
      },
    );
  }
}
