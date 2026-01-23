import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class CommonLoadingBody extends StatelessWidget {
  const CommonLoadingBody({
    super.key,
    this.child = const SizedBox(),
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
    return Stack(
      alignment: Alignment.center,
      children: [
        Visibility(
          visible: loading,
          child: Align(
            alignment: alignment,
            child: LoadingAnimationWidget.threeArchedCircle(
              color: color ?? Theme.of(context).colorScheme.primary,
              size: size,
            ),
          ),
        ),
        Visibility(
          visible: !loading,
          maintainState: true,
          maintainAnimation: true,
          maintainSize: true,
          child: child,
        ),
      ],
    );
  }
}
