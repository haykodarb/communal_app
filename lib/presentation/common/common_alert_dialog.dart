import 'package:flutter/material.dart';

class CommonAlertDialog extends StatelessWidget {
  const CommonAlertDialog({
    super.key,
    required this.title,
    this.confirmCallback,
    this.confirmationText = 'Accept',
  });

  final void Function()? confirmCallback;
  final String title;
  final String confirmationText;

  void open(BuildContext context) {
    showDialog(context: context, builder: build);
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
            SizedBox(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            SizedBox(
              child: ElevatedButton(
                onPressed: confirmCallback ?? () => Navigator.of(context).pop(),
                child: Text(confirmationText),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
