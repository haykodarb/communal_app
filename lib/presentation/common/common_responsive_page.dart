import 'package:communal/presentation/common/common_drawer/common_drawer_widget.dart';
import 'package:communal/responsive.dart';
import 'package:flutter/material.dart';

class CommonResponsivePage extends StatelessWidget {
  const CommonResponsivePage({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final Color borderColor =
        Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5);

    return Responsive(
      mobile: child,
      tablet: Scaffold(
        body: Row(
          children: [
            const Expanded(
              child: SizedBox(),
            ),
            VerticalDivider(
              thickness: 1,
              width: 1,
              color: borderColor,
            ),
            SizedBox(
              width: 300,
              child: CommonDrawerWidget(),
            ),
            VerticalDivider(
              thickness: 1,
              width: 1,
              color: borderColor,
            ),
            SizedBox(
              width: 497,
              child: child,
            ),
            VerticalDivider(
              thickness: 1,
              width: 1,
              color: borderColor,
            ),
            const Expanded(
              child: SizedBox(),
            ),
          ],
        ),
      ),
      desktop: Scaffold(
        body: Row(
          children: [
            const Expanded(
              flex: 2,
              child: SizedBox(),
            ),
            VerticalDivider(
              thickness: 1,
              width: 1,
              color: borderColor,
            ),
            Expanded(
              flex: 2,
              child: CommonDrawerWidget(),
            ),
            VerticalDivider(
              thickness: 1,
              width: 1,
              color: borderColor,
            ),
            Expanded(
              flex: 3,
              child: child,
            ),
            VerticalDivider(
              thickness: 1,
              width: 1,
              color: borderColor,
            ),
            const Expanded(
              flex: 2,
              child: SizedBox(),
            ),
          ],
        ),
      ),
    );
  }
}
