import 'package:communal/presentation/common/common_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// A centered placeholder for a list that failed to load: an error-tinted
/// icon, the message and, when there's a way back in, "Try again".
class CommonErrorState extends StatelessWidget {
  const CommonErrorState({
    super.key,
    required this.message,
    this.onRetry,
  });

  final String message;
  final void Function()? onRetry;

  @override
  Widget build(BuildContext context) {
    final Color error = Theme.of(context).colorScheme.error;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: error.withValues(alpha: 0.15),
            ),
            child: Icon(Icons.close, size: 24, color: error),
          ),
          const SizedBox(height: 12),
          Text(
            message.tr,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, height: 1.4, color: error),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 12),
            CommonButton(
              type: CommonButtonType.tonal,
              expand: false,
              onPressed: (_) => onRetry!(),
              child: Text('Try again'.tr),
            ),
          ],
        ],
      ),
    );
  }
}
