import 'package:communal/presentation/common/common_pill_button.dart';
import 'package:flutter/material.dart';

/// A centered placeholder for an empty list: a muted icon, a title (a "\n"
/// starts a new line) and an optional action, a filled pill button.
class CommonEmptyState extends StatelessWidget {
  const CommonEmptyState({
    super.key,
    required this.title,
    this.icon,
    this.actionLabel,
    this.actionIcon,
    this.onAction,
  });

  final String title;
  final IconData? icon;
  final String? actionLabel;
  final IconData? actionIcon;
  final void Function(BuildContext)? onAction;

  @override
  Widget build(BuildContext context) {
    final Color muted = Theme.of(context).colorScheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 40, color: muted),
            const SizedBox(height: 10),
          ],
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, height: 1.4, color: muted),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 16),
            CommonPillButton(
              icon: actionIcon ?? Icons.arrow_forward,
              label: actionLabel,
              filled: true,
              onPressed: onAction!,
            ),
          ],
        ],
      ),
    );
  }
}
