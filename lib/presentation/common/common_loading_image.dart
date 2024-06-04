import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class CommonLoadingImage extends StatelessWidget {
  const CommonLoadingImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.surface,
      highlightColor: Theme.of(context).colorScheme.surfaceContainer,
      period: const Duration(milliseconds: 750),
      enabled: true,
      child: Container(
        color: Colors.black,
      ),
    );
  }
}
