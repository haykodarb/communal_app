import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class CommonLoadingBody extends StatelessWidget {
  const CommonLoadingBody({
    super.key,
    required this.child,
    required this.loading,
    this.size = 50,
  });

  final Widget child;
  final RxBool loading;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        if (loading.value) {
          return Center(
            // child: LoadingAnimationWidget.flickr(
            //   leftDotColor: Get.theme.colorScheme.primary,
            //   rightDotColor: Get.theme.colorScheme.secondary,
            //   size: size,
            // ),
            child: LoadingAnimationWidget.threeArchedCircle(color: Get.theme.colorScheme.primary, size: size),
          );
        }

        return child;
      },
    );
  }
}
