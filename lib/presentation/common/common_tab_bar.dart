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
    final Color selectedFg = Theme.of(context).colorScheme.onPrimary;
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
      padding: const EdgeInsets.all(10),
      height: 70,
      width: double.maxFinite,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(50),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double widthOfTab = constraints.maxWidth / tabs.length;

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
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                ),
              ),
              Row(
                children: children(20),
              ),
            ],
          );
        },
      ),
    );
  }
}
