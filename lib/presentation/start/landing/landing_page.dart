import 'package:communal/presentation/common/common_button.dart';
import 'package:communal/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

class LandingController extends GetxController {
  final RxInt pageIndex = 0.obs;
}

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  // ignore: unused_field
  static const List<String> _images = [
    'assets/crow.svg',
    'assets/crow.svg',
    'assets/crow.svg',
  ];

  static final List<String> _titles = [
    'Upload your books'.tr,
    'Join communities'.tr,
    'Share books'.tr
  ];

  static final List<String> _copies = [
    'landing-upload-books'.tr,
    'landing-join-communities'.tr,
    'landing-share-books'.tr,
  ];

  Widget _pageIndicator(BuildContext context, LandingController controller) {
    final Color selectedColor = Theme.of(context).colorScheme.primary;
    final Color unselectedColor =
        Theme.of(context).colorScheme.primary.withValues(alpha: 0.4);

    return SizedBox(
      width: 200,
      height: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Obx(
            () {
              return Container(
                width: controller.pageIndex.value == 0 ? 60 : 20,
                height: 20,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: controller.pageIndex.value == 0
                      ? selectedColor
                      : unselectedColor,
                ),
              );
            },
          ),
          const VerticalDivider(width: 10),
          Obx(
            () {
              return Container(
                width: controller.pageIndex.value == 1 ? 45 : 20,
                height: 20,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: controller.pageIndex.value == 1
                      ? selectedColor
                      : unselectedColor,
                ),
              );
            },
          ),
          const VerticalDivider(width: 10),
          Obx(
            () {
              return Container(
                width: controller.pageIndex.value == 2 ? 45 : 20,
                height: 20,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: controller.pageIndex.value == 2
                      ? selectedColor
                      : unselectedColor,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final LinearGradient gradient = LinearGradient(
      colors: [
        Theme.of(context).colorScheme.primary,
        Theme.of(context).colorScheme.tertiary,
      ],
    );

    return GetBuilder(
      init: LandingController(),
      builder: (controller) {
        return Scaffold(
          body: SafeArea(
            child: Center(
              child: SizedBox(
                width: 600,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Divider(height: 30),
                      Expanded(
                        child: Container(
                          alignment: Alignment.bottomCenter,
                          child: ShaderMask(
                            blendMode: BlendMode.srcIn,
                            shaderCallback: (bounds) => gradient.createShader(
                              Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                            ),
                            child: SvgPicture.asset(
                              'assets/crow.svg',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      const Divider(height: 30),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Obx(
                              () {
                                return Text(
                                  _titles[controller.pageIndex.value],
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 24,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                                  textAlign: TextAlign.center,
                                );
                              },
                            ),
                            const Divider(height: 20),
                            Obx(
                              () {
                                return Text(
                                  _copies[controller.pageIndex.value],
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                                  textAlign: TextAlign.center,
                                );
                              },
                            ),
                            const Divider(height: 30),
                            _pageIndicator(context, controller),
                            const Divider(height: 30),
                            CommonButton(
                              type: CommonButtonType.filled,
                              onPressed: (BuildContext ctx) {
                                controller.pageIndex.value++;
                                if (controller.pageIndex.value >= 3) {
                                  ctx.go(RouteNames.startPage);
                                }
                              },
                              child: const Text('Next'),
                            ),
                            const Divider(height: 20),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
