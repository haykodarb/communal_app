import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class CommonLoadingBody extends StatelessWidget {
  const CommonLoadingBody({
    super.key,
    required this.child,
    required this.loading,
    this.size = 50,
  });

  final Widget child;
  final bool loading;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Center(
        // child: LoadingAnimationWidget.flickr(
        //   leftDotColor: Theme.of(context).colorScheme.primary,
        //   rightDotColor: Theme.of(context).colorScheme.secondary,
        //   size: size,
        // ),
        child: LoadingAnimationWidget.threeArchedCircle(color: Theme.of(context).colorScheme.primary, size: size),
      );
    }

    return child;
  }
}
