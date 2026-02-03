import 'package:communal/presentation/common/common_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CommonConfirmationDialog extends StatelessWidget {
  const CommonConfirmationDialog({
    super.key,
    required this.title,
    this.confirmCallback,
    this.cancelCallback,
    this.confirmationText = 'Yes',
    this.cancelText = 'No',
  });

  final void Function(BuildContext context)? confirmCallback;
  final void Function(BuildContext context)? cancelCallback;
  final String title;
  final String confirmationText;
  final String cancelText;

  Future<bool> open(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: build,
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 400,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Theme.of(context).colorScheme.surface,
          border: Border.all(
            color: Theme.of(context).colorScheme.primary,
            width: 0.5,
          ),
        ),
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Divider(height: 20),
            Center(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20),
              ),
            ),
            const Divider(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: CommonButton(
                    onPressed: confirmCallback ??
                        (BuildContext _) => context.pop(true),
                    child: Text(
                      confirmationText,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const VerticalDivider(width: 20),
                Expanded(
                  child: CommonButton(
                    type: CommonButtonType.outlined,
                    onPressed: cancelCallback ??
                        (BuildContext _) => context.pop(false),
                    expand: true,
                    child: Text(
                      cancelText,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
