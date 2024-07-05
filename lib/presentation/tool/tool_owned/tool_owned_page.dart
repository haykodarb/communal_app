import 'package:atlas_icons/atlas_icons.dart';
import 'package:communal/backend/tools_backend.dart';
import 'package:communal/models/loan.dart';
import 'package:communal/presentation/common/common_loading_image.dart';
import 'package:communal/presentation/common/common_text_info.dart';
import 'package:communal/presentation/tool/tool_owned/tool_owned_controller.dart';
import 'package:communal/routes.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ToolOwnedPage extends StatelessWidget {
  const ToolOwnedPage({super.key});

  Widget _toolReview(ToolOwnedController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Obx(
        () {
          return CommonTextInfo(
            label: 'Description',
            text: controller.tool.value.description,
            size: 14,
          );
        },
      ),
    );
  }

  Widget _existingLoan(Loan loan) {
    return Builder(
      builder: (context) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              'Borrowed by',
              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
            ),
            TextButton(
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                alignment: Alignment.topLeft,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: () {
                Get.toNamed(
                  RouteNames.messagesSpecificPage,
                  arguments: {
                    'user': loan.loanee,
                  },
                );
              },
              child: Text(
                loan.loanee.username,
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
            ),
            const Divider(height: 20),
            Text(
              'Since',
              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
            ),
            Text(DateFormat.yMMMd().format(loan.accepted_at!.toLocal()))
          ],
        );
      },
    );
  }

  Widget _toolInformation(ToolOwnedController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Obx(
        () => controller.loading.value
            ? const SizedBox.shrink()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CommonTextInfo(
                    label: 'Added',
                    text: DateFormat.yMMMd().format(controller.tool.value.created_at.toLocal()),
                    size: 14,
                  ),
                  const Divider(),
                  controller.currentLoan.value != null
                      ? Obx(
                          () => _existingLoan(controller.currentLoan.value!),
                        )
                      : CommonTextInfo(
                          label: 'Available',
                          text: controller.tool.value.available ? 'Yes' : 'No',
                          size: 14,
                        ),
                ],
              ),
      ),
    );
  }

  Widget _toolTitle(ToolOwnedController controller) {
    return Builder(
      builder: (context) {
        return Container(
          width: double.maxFinite,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            controller.tool.value.name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: ToolOwnedController(),
      builder: (ToolOwnedController controller) {
        return Scaffold(
          appBar: AppBar(
            actions: [
              IconButton(
                onPressed: controller.editTool,
                icon: const Icon(Atlas.pencil_edit),
              ),
              const VerticalDivider(width: 5),
              IconButton(
                onPressed: controller.deleteTool,
                icon: const Icon(Atlas.trash),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 30),
                  _toolTitle(controller),
                  const Divider(height: 30),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 5,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: AspectRatio(
                            aspectRatio: 3 / 4,
                            child: FutureBuilder(
                              future: ToolsBackend.getToolImage(controller.tool.value),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return const CommonLoadingImage();
                                }

                                return Image.memory(
                                  snapshot.data!,
                                  fit: BoxFit.cover,
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: _toolInformation(controller),
                      ),
                    ],
                  ),
                  const Divider(height: 30),
                  _toolReview(controller),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
