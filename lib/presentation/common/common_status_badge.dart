import 'package:flutter/material.dart';

/// available / returned: green, loaned: purple (the book list's colours),
/// requested: primary, rejected: error.
enum StatusTone { available, loaned, requested, rejected }

/// A status as a small tinted chip with a coloured dot (book and loan pages).
class CommonStatusBadge extends StatelessWidget {
  const CommonStatusBadge({
    super.key,
    required this.tone,
    required this.label,
  });

  static const Color green = Color(0xFF7DAE6B);

  final StatusTone tone;
  final String label;

  static Color colorOf(BuildContext context, StatusTone tone) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return switch (tone) {
      StatusTone.available => green,
      StatusTone.loaned => colors.tertiary,
      StatusTone.requested => colors.primary,
      StatusTone.rejected => colors.error,
    };
  }

  @override
  Widget build(BuildContext context) {
    final Color color = colorOf(context, tone);

    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
