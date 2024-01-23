import 'dart:async';
import 'package:communal/backend/tools_backend.dart';
import 'package:communal/models/backend_response.dart';
import 'package:communal/models/tool.dart';
import 'package:communal/presentation/common/common_alert_dialog.dart';
import 'package:communal/routes.dart';
import 'package:get/get.dart';

class ToolListController extends GetxController {
  final RxList<Tool> userTools = <Tool>[].obs;
  final RxBool loading = true.obs;
  Timer? debounceTimer;

  @override
  Future<void> onReady() async {
    super.onReady();

    await reloadTools();
  }

  Future<void> deleteTool(Tool tool) async {
    tool.loading.value = true;

    final BackendResponse response = await ToolsBackend.deleteTool(tool);

    if (response.success) {
      userTools.remove(tool);
      userTools.refresh();
    } else {
      tool.loading.value = false;

      Get.dialog(
        CommonAlertDialog(title: '${response.payload}'),
      );
    }
  }

  Future<void> searchTools(String query) async {
    debounceTimer?.cancel();

    debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      loading.value = true;

      final BackendResponse response = await ToolsBackend.searchOwnerToolsByQuery(query);

      if (response.success) {
        userTools.value = response.payload;
        userTools.refresh();
      }

      loading.value = false;
    });
  }

  Future<void> updateTool(Tool tool) async {
    final int indexOfTool = userTools.indexWhere((element) => element.id == tool.id);

    if (indexOfTool >= 0) {
      userTools[indexOfTool] = tool;
      userTools.refresh();
    }
  }

  Future<void> reloadTools() async {
    loading.value = true;
    final BackendResponse response = await ToolsBackend.getAllToolsForUser();
    loading.value = false;

    if (response.success) {
      userTools.value = response.payload;
      userTools.refresh();
    }
  }

  Future<void> goToAddToolPage() async {
    final dynamic result = await Get.toNamed(RouteNames.toolCreatePage);

    if (result != null) {
      userTools.add(result);
      userTools.refresh();
    }
  }
}
