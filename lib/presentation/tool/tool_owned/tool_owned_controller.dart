import 'package:communal/backend/loans_backend.dart';
import 'package:communal/models/backend_response.dart';
import 'package:communal/models/loan.dart';
import 'package:communal/models/tool.dart';
import 'package:communal/presentation/common/common_confirmation_dialog.dart';
import 'package:communal/presentation/tool/tool_list_controller.dart';
import 'package:communal/routes.dart';
import 'package:get/get.dart';

class ToolOwnedController extends GetxController {
  final Rx<Tool> tool = Tool.empty().obs;

  final ToolListController? myToolsController = Get.arguments['controller'];

  final RxBool loading = false.obs;

  Rxn<Loan> currentLoan = Rxn<Loan>();

  @override
  Future<void> onInit() async {
    tool.value = Get.arguments['tool'];
    tool.refresh();

    await loadCurrentLoan();

    super.onInit();
  }

  Future<void> deleteTool() async {
    final bool deleteConfirm = await Get.dialog<bool>(
          CommonConfirmationDialog(
            title: 'Delete tool?',
            confirmCallback: () => Get.back<bool>(result: true),
            cancelCallback: () => Get.back<bool>(result: false),
          ),
        ) ??
        false;

    if (deleteConfirm) {
      myToolsController?.deleteTool(tool.value);
      Get.back();
    }
  }

  Future<void> loadCurrentLoan() async {
    loading.value = true;

    final BackendResponse response = await LoansBackend.getCurrentLoanForTool(tool.value);

    if (response.success) {
      currentLoan.value = response.payload;
      currentLoan.refresh();
    }

    loading.value = false;
  }

  Future<void> editTool() async {
    final Tool? response = await Get.toNamed<dynamic>(
      RouteNames.toolEditPage,
      arguments: {
        'tool': tool.value,
      },
    );

    if (response != null) {
      tool.value = response;
      tool.refresh();
    }
  }
}
