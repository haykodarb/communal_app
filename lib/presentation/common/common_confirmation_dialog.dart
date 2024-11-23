import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CommonConfirmationDialog extends StatelessWidget {
  const CommonConfirmationDialog({
    super.key,
    required this.title,
    this.confirmCallback,
    this.cancelCallback,
    this.confirmationText = 'Yes',
    this.cancelText = 'Cancel',
  });

  final void Function()? confirmCallback;
  final void Function()? cancelCallback;
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
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Theme.of(context).colorScheme.surface,
          border: Border.all(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: confirmCallback ?? () => context.pop(true),
                    child: Text(confirmationText),
                  ),
                ),
                const VerticalDivider(width: 20),
                Expanded(
                  child: OutlinedButton(
                    onPressed: cancelCallback ?? () => context.pop(false),
                    child: Text(cancelText),
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
