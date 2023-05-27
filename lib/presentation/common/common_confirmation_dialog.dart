import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CommonConfirmationDialog extends StatelessWidget {
  const CommonConfirmationDialog({
    super.key,
    required this.title,
    required this.confirmCallback,
    required this.cancelCallback,
    this.confirmationText = 'Yes',
    this.cancelText = 'No',
  });

  final void Function() confirmCallback;
  final void Function() cancelCallback;
  final String title;
  final String confirmationText;
  final String cancelText;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Get.theme.colorScheme.background,
          border: Border.all(
            color: Get.theme.colorScheme.primary,
            width: 0.25,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        height: 225,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 200,
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: 100,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: confirmCallback,
                    child: Text(confirmationText),
                  ),
                ),
                SizedBox(
                  width: 100,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: cancelCallback,
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
