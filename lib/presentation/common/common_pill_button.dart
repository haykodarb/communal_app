import 'package:communal/presentation/common/common_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// The small rounded buttons in profile headers and list rows (add friend,
/// accept, message, ...): an icon with an optional label, 35px tall.
class CommonPillButton extends StatelessWidget {
  const CommonPillButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.label,
    this.filled = false,
    this.loading,
  });

  final IconData icon;
  final String? label;
  final bool filled;
  final RxBool? loading;
  final void Function(BuildContext) onPressed;

  static const EdgeInsets _padding = EdgeInsets.symmetric(horizontal: 12);

  @override
  Widget build(BuildContext context) {
    if (label == null) {
      return SizedBox(
        height: 35,
        child: AspectRatio(
          aspectRatio: 1,
          child: CommonButton(
            type: filled
                ? CommonButtonType.filledIcon
                : CommonButtonType.outlinedIcon,
            expand: false,
            loading: loading,
            loaderSize: 20,
            onPressed: onPressed,
            child: Icon(icon, size: 16),
          ),
        ),
      );
    }

    return SizedBox(
      height: 35,
      child: CommonButton(
        type: filled ? CommonButtonType.filled : CommonButtonType.outlined,
        expand: false,
        loading: loading,
        loaderSize: 20,
        style: filled
            ? FilledButton.styleFrom(padding: _padding)
            : OutlinedButton.styleFrom(
                padding: _padding,
                side: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 1.5,
                ),
              ),
        onPressed: onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16),
            const VerticalDivider(width: 4),
            Text(
              label!,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
