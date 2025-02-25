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

  static const List<String> _images = [
    'assets/crow.svg',
    'assets/crow.svg',
    'assets/crow.svg',
  ];

  static const List<String> _titles = ['Subí tus libros', 'Unite a comunidades', 'Compartí libros'];

  static const List<String> _copies = [
    'Showcase your book collection to your peers. Give each book a new purpose by lending it out, building shared stories along the way.',
    'One of your friends has a book on their shelf that you\'ve been dying to read? Join a mutual community and ask if you can loan it out for a bit.',
    'Review the books you\'ve read and discuss them with other community members. Share your insights and perspectives with like-minded people.',
  ];

  Widget _pageIndicator(BuildContext context, LandingController controller) {
    final Color selectedColor = Theme.of(context).colorScheme.primary;
    final Color unselectedColor = Theme.of(context).colorScheme.primary.withOpacity(0.4);

    return SizedBox(
      width: 150,
      height: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Obx(
            () {
              return Container(
                width: controller.pageIndex.value == 0 ? 45 : 20,
                height: 20,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: controller.pageIndex.value == 0 ? selectedColor : unselectedColor,
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
                  color: controller.pageIndex.value == 1 ? selectedColor : unselectedColor,
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
                  color: controller.pageIndex.value == 2 ? selectedColor : unselectedColor,
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
    return GetBuilder(
      init: LandingController(),
      builder: (controller) {
        return Scaffold(
          body: SafeArea(
            child: Center(
              child: SizedBox(
                width: 600,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  child: Column(
                    children: [
                      const Divider(height: 40),
                      Expanded(
                        child: Container(
                          alignment: Alignment.bottomCenter,
                          child: SvgPicture.asset(
                            'assets/crow.svg',
                            fit: BoxFit.scaleDown,
                          ),
                        ),
                      ),
                      const Divider(height: 40),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Obx(
                              () {
                                return Text(
                                  _titles[controller.pageIndex.value],
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 24,
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                  textAlign: TextAlign.center,
                                );
                              },
                            ),
                            const Divider(height: 20),
                            SizedBox(
                              height: 75,
                              child: Center(
                                child: Obx(
                                  () {
                                    return Text(
                                      _copies[controller.pageIndex.value],
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16,
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      ),
                                      textAlign: TextAlign.center,
                                    );
                                  },
                                ),
                              ),
                            ),
                            const Divider(height: 40),
                            _pageIndicator(context, controller),
                            const Divider(height: 40),
                            ElevatedButton(
                                onPressed: () {
                                  controller.pageIndex.value++;
                                  if (controller.pageIndex.value >= 3) {
                                    context.go(RouteNames.startPage);
                                  }
                                },
                                child: const Text('Next')),
                            const Divider(height: 20),
                            TextButton(
                              onPressed: () {
                                context.go(RouteNames.startPage);
                              },
                              style: TextButton.styleFrom(
                                textStyle: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              child: const Text('Skip'),
                            ),
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
