import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CommonTabBar extends StatelessWidget {
  const CommonTabBar({
    super.key,
    required this.onTabTapped,
    required this.currentIndex,
    required this.tabs,
  });

  final void Function(int) onTabTapped;
  final RxInt currentIndex;
  final List<String> tabs;

  @override
  Widget build(BuildContext context) {
    final Color selectedBg = Theme.of(context).colorScheme.primary;
    final Color selectedFg = Theme.of(context).colorScheme.primary;
    final int length = tabs.length;

    int lengthOfLongestTab = 0;
    for (String value in tabs) {
      if (value.length > lengthOfLongestTab) {
        lengthOfLongestTab = value.length;
      }
    }

    List<Widget> children(double fontSize) {
      return List.generate(
        length,
        (index) {
          return Expanded(
            child: InkWell(
              onTap: () => onTabTapped(index),
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              child: Container(
                alignment: Alignment.center,
                color: Colors.transparent,
                child: Obx(
                  () => AnimatedDefaultTextStyle(
                    style: TextStyle(
                      color:
                          currentIndex.value == index ? selectedFg : selectedBg,
                      fontWeight: FontWeight.w600,
                      fontSize: fontSize,
                    ),
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      tabs[index],
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
    }

    return Container(
      padding: const EdgeInsets.all(5),
      height: 70,
      width: double.maxFinite,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(50),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double widthOfTab = constraints.maxWidth / tabs.length;
          final double heightOfTab = constraints.maxHeight;

          String longestTab =
              tabs.reduce((a, b) => a.length > b.length ? a : b);

          double calculateFontSize(
            BuildContext context,
            String text,
            double maxWidth,
            double maxHeight,
          ) {
            const double widthPadding = 8;
            const double heightPadding = 4;
            double effectiveWidth = maxWidth - widthPadding;
            double effectiveHeight = maxHeight - heightPadding;

            TextScaler textScaler = MediaQuery.textScalerOf(context);
            double textScaleFactor = textScaler.scale(1.0);
            double fontSize = 20;
            double scaledFontSize = textScaler.scale(fontSize);

            final defaultStyle = DefaultTextStyle.of(context).style;
            final textStyle = defaultStyle.merge(TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: scaledFontSize,
            ));
            final textPainter = TextPainter(
              text: TextSpan(text: text, style: textStyle),
              textDirection: TextDirection.ltr,
            );
            textPainter.layout();
            double measuredWidth = textPainter.width;
            double measuredHeight = textPainter.height;

            double widthScale = effectiveWidth / measuredWidth;
            double heightScale = effectiveHeight / measuredHeight;
            double scale = widthScale < heightScale ? widthScale : heightScale;

            scaledFontSize = scaledFontSize * scale;
            fontSize = textScaleFactor == 0
                ? fontSize
                : scaledFontSize / textScaleFactor;

            fontSize = fontSize.floorToDouble();
            return fontSize.clamp(12, 20);
          }

          final double fontSize =
              calculateFontSize(context, longestTab, widthOfTab, heightOfTab);

          return Stack(
            children: [
              Obx(
                () => AnimatedSlide(
                  offset: Offset(currentIndex.value.toDouble(), 0),
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    height: double.maxFinite,
                    width: constraints.maxWidth / length,
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                ),
              ),
              Row(
                children: children(fontSize),
              ),
            ],
          );
        },
      ),
    );
  }
}
