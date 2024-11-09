import 'package:flutter/material.dart';

class Responsive extends StatelessWidget {
  const Responsive(
      {super.key, required this.mobile, required this.desktop, this.tablet});

  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  static bool isMobile(BuildContext context) {
    return MediaQuery.sizeOf(context).width < 800;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= 1400;
  }

  static bool isTablet(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= 800 &&
        MediaQuery.sizeOf(context).width < 1400;
  }

  @override
  Widget build(BuildContext context) {
    if (isDesktop(context)) {
      return desktop;
    } else if (isMobile(context)) {
      return mobile;
    } else if (tablet != null && isTablet(context)) {
      return tablet!;
    }

    return const SizedBox.shrink();
  }
}
