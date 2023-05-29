import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class CommonLoadingBody extends StatelessWidget {
  const CommonLoadingBody({
    super.key,
    required this.child,
    required this.isLoading,
    this.size = 50,
  });

  final Widget child;
  final bool isLoading;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: LoadingAnimationWidget.flickr(
          leftDotColor: Get.theme.colorScheme.primary,
          rightDotColor: Get.theme.colorScheme.secondary,
          size: size,
        ),
      );
    }

    return child;
  }
}
