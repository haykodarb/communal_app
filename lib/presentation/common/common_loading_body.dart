import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class CommonLoadingBody extends StatelessWidget {
  const CommonLoadingBody({
    super.key,
    this.child = const SizedBox.shrink(),
    this.loading = true,
    this.size = 50,
    this.alignment = Alignment.center,
    this.color,
  });

  final Widget child;
  final bool loading;
  final double size;
  final Alignment alignment;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Align(
        alignment: alignment,
        child: LoadingAnimationWidget.threeArchedCircle(
          color: color ?? Theme.of(context).colorScheme.primary,
          size: size,
        ),
      );
    }

    return child;
  }
}
