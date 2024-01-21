import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class CommonLoadingBody extends StatelessWidget {
  const CommonLoadingBody({
    super.key,
    required this.child,
    required this.loading,
    this.size = 50,
    this.alignment = Alignment.center,
  });

  final Widget child;
  final bool loading;
  final double size;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Align(
        alignment: alignment,
        child: LoadingAnimationWidget.threeArchedCircle(color: Theme.of(context).colorScheme.primary, size: size),
      );
    }

    return child;
  }
}
