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
      width: 110,
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: value ? Theme.of(context).colorScheme.primary : Colors.transparent,
                ),
                padding: EdgeInsets.zero,
                child: Icon(
                  Icons.check,
                  size: 22,
                  color: value ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.primary,
                ),
              ),
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: value ? Colors.transparent : Theme.of(context).colorScheme.primary,
                ),
                padding: EdgeInsets.zero,
                child: Icon(
                  Icons.close,
                  size: 22,
                  color: value ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
