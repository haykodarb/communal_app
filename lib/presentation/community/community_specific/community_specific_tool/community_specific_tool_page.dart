import 'package:communal/backend/tools_backend.dart';
import 'package:communal/backend/users_backend.dart';
import 'package:communal/models/tool.dart';
import 'package:communal/models/loan.dart';
import 'package:communal/presentation/common/common_circular_avatar.dart';
import 'package:communal/presentation/common/common_loading_image.dart';
import 'package:communal/presentation/common/common_text_info.dart';
import 'package:communal/presentation/common/common_username_button.dart';
import 'package:communal/presentation/community/community_specific/community_specific_tool/community_specific_tool_controller.dart';
import 'package:communal/routes.dart';
import 'package:expandable_page_view/expandable_page_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class CommunitySpecificToolPage extends StatelessWidget {
  const CommunitySpecificToolPage({super.key});

  Widget _toolName(Tool tool) {
    return Builder(
      builder: (context) {
        return Container(
          width: double.maxFinite,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            tool.name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        );
      },
    );
  }

  Widget _toolDescription(CommunitySpecificToolController controller) {
    return Builder(
      builder: (context) {
        return SizedBox(
          width: double.maxFinite,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommonTextInfo(
                label: 'Description',
                text: controller.tool.description,
                size: 14,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _reviewCard(CommunitySpecificToolController controller, int index) {
    final Loan loan = controller.completedLoans[index];
    return SizedBox(
      width: double.maxFinite,
      child: InkWell(
        onTap: () {
          controller.expandCarouselItem.value = !controller.expandCarouselItem.value;
        },
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CommonCircularAvatar(
                      profile: loan.loanee,
                      radius: 20,
                      clickable: true,
                    ),
                    const VerticalDivider(width: 10),
                    CommonUsernameButton(user: loan.loanee),
                  ],
                ),
                const Divider(),
                Obx(
                  () => Text(
                    loan.review ?? '',
                    overflow: controller.expandCarouselItem.value ? TextOverflow.visible : TextOverflow.ellipsis,
                    maxLines: controller.expandCarouselItem.value ? null : 5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _borrowersReviews(CommunitySpecificToolController controller) {
    return Builder(builder: (context) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.maxFinite,
            child: Text(
              'Borrowers\' Reviews',
              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
            ),
          ),
          Obx(
            () {
              if (controller.loadingCarousel.value) {
                return SizedBox(
                  height: 100,
                  width: double.maxFinite,
                  child: LoadingAnimationWidget.threeArchedCircle(
                    color: Theme.of(context).colorScheme.primary,
                    size: 30,
                  ),
                );
              }

              if (controller.completedLoans.isEmpty) {
                return const Text('No other reviews available.');
              }

              return Column(
                children: [
                  const Divider(),
                  ExpandablePageView.builder(
                    itemCount: controller.completedLoans.length,
                    onPageChanged: (value) {
                      controller.carouselIndex.value = value;
                    },
                    itemBuilder: (context, index) {
                      return LayoutBuilder(
                        builder: (context, constraints) {
                          return Align(
                            alignment: Alignment.topCenter,
                            child: _reviewCard(controller, index),
                          );
                        },
                      );
                    },
                  ),
                  const Divider(),
                  Visibility(
                    visible: controller.completedLoans.length > 1,
                    child: Container(
                      alignment: Alignment.center,
                      height: 10,
                      width: double.maxFinite,
                      child: ListView.builder(
                        itemCount: controller.completedLoans.length,
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          return Obx(
                            () => Container(
                              height: 30,
                              width: 30,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: index == controller.carouselIndex.value
                                    ? Theme.of(context).colorScheme.tertiary
                                    : Theme.of(context).colorScheme.tertiary.withOpacity(0.1),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const Divider(),
        ],
      );
    });
  }

  Widget _sideInformation(CommunitySpecificToolController controller) {
    final Tool tool = controller.tool;

    return Builder(
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Owner',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Get.toNamed(
                        RouteNames.profileOtherPage,
                        arguments: {
                          'user': tool.owner,
                        },
                      );
                    },
                    child: Text(tool.owner.username),
                  ),
                  const Divider(),
                  CommonTextInfo(label: 'Added', text: DateFormat.yMMMd().format(tool.created_at), size: 14),
                  const Divider(),
                  CommonTextInfo(label: 'Available', text: tool.available ? 'Yes' : 'No', size: 14),
                  const Divider(),
                  Obx(
                    () {
                      if (controller.loading.value) {
                        return LoadingAnimationWidget.horizontalRotatingDots(
                          color: Theme.of(context).colorScheme.primary,
                          size: 20,
                        );
                      }

                      final Loan? currentLoan = controller.currentLoan.value;

                      if (currentLoan != null) {
                        final bool loanedByCurrentUser = currentLoan.loanee.id == UsersBackend.currentUserId;

                        if (!loanedByCurrentUser) {
                          return const SizedBox.shrink();
                        }

                        if (loanedByCurrentUser && currentLoan.accepted) {
                          return CommonTextInfo(
                            label: 'Status',
                            text: 'Borrowed ${DateFormat.yMMMd().format(currentLoan.accepted_at!)}',
                            size: 14,
                          );
                        }

                        if (loanedByCurrentUser) {
                          return CommonTextInfo(
                            label: 'Status',
                            text: 'Requested ${DateFormat.yMMMd().format(currentLoan.created_at)}',
                            size: 14,
                          );
                        } else {
                          return const SizedBox.shrink();
                        }
                      } else {
                        if (!tool.available) {
                          return const SizedBox.shrink();
                        }

                        return MaterialButton(
                          onPressed: controller.requestLoan,
                          color: Theme.of(context).colorScheme.primary,
                          padding: const EdgeInsets.all(8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.arrow_circle_down,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                              const VerticalDivider(width: 5),
                              Text(
                                'Request',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onPrimary,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: CommunitySpecificToolController(),
      builder: (CommunitySpecificToolController controller) {
        return Scaffold(
          appBar: AppBar(),
          body: SingleChildScrollView(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _toolName(controller.tool),
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
                                future: ToolsBackend.getToolImage(controller.tool),
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
                          child: _sideInformation(controller),
                        ),
                      ],
                    ),
                    const Divider(height: 30),
                    _toolDescription(controller),
                    const Divider(height: 30),
                    _borrowersReviews(controller),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
