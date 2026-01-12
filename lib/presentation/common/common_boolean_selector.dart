import 'package:flutter/material.dart';

class CommonBooleanSelector extends StatelessWidget {
  const CommonBooleanSelector({
    super.key,
    required this.callback,
    required this.value,
  });

  final void Function() callback;
  final bool value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      width: 100,
      child: InkWell(
        onTap: callback,
        overlayColor: WidgetStateColor.transparent,
        highlightColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Stack(
            children: [
              AnimatedSlide(
                offset: value ? Offset.zero : const Offset(1, 0),
                duration: const Duration(milliseconds: 200),
                child: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: 40,
                    width: 40,
                    padding: EdgeInsets.zero,
                    color: Colors.transparent,
                    child: TweenAnimationBuilder(
                      duration: const Duration(milliseconds: 200),
                      tween: ColorTween(
                        begin: value
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onPrimary,
                        end: value
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.primary,
                      ),
                      builder: (context, color, child) {
                        return Icon(
                          Icons.check,
                          size: 22,
                          color: color,
                        );
                      },
                    ),
                  ),
                  Container(
                    height: 40,
                    width: 40,
                    padding: EdgeInsets.zero,
                    color: Colors.transparent,
                    child: TweenAnimationBuilder(
                      duration: const Duration(milliseconds: 200),
                      tween: ColorTween(
                        begin: value
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.primary,
                        end: value
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onPrimary,
                      ),
                      builder: (context, color, child) {
                        return Icon(
                          Icons.close,
                          size: 22,
                          color: color,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
