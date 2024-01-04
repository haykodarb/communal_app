import 'package:flutter/material.dart';

class CommonTextField extends StatelessWidget {
  const CommonTextField({
    super.key,
    required this.callback,
    required this.label,
    required this.validator,
    this.minLines = 1,
    this.maxLines = 1,
    this.maxLength = 60,
    this.initialValue,
  });

  final void Function(String) callback;
  final String? Function(String?) validator;
  final int minLines;
  final int maxLines;
  final int? maxLength;
  final String? initialValue;
  final String label;

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController(text: initialValue);

    return TextFormField(
      validator: validator,
      cursorColor: Theme.of(context).colorScheme.primary,
      onChanged: callback,
      controller: controller,
      minLines: minLines,
      maxLines: maxLines,
      maxLength: maxLength,
      decoration: InputDecoration(
        counter: const SizedBox.shrink(),
        label: Text(
          label,
        ),
        alignLabelWithHint: true,
      ),
    );
  }
}

class CommonPasswordField extends StatefulWidget {
  const CommonPasswordField({
    super.key,
    required this.callback,
    required this.label,
    required this.validator,
    this.minLines = 1,
    this.maxLines = 1,
    this.maxLength = 60,
  });

  final void Function(String) callback;
  final String? Function(String?) validator;
  final int minLines;
  final int maxLines;
  final int? maxLength;
  final String label;
  @override
  State<CommonPasswordField> createState() => _CommonPasswordFieldState();
}

class _CommonPasswordFieldState extends State<CommonPasswordField> {
  bool isVisible = false;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: widget.validator,
      cursorColor: Theme.of(context).colorScheme.primary,
      onChanged: widget.callback,
      obscureText: !isVisible,
      minLines: widget.minLines,
      maxLines: widget.maxLines,
      maxLength: widget.maxLength,
      decoration: InputDecoration(
        counter: const SizedBox.shrink(),
        suffixIcon: IconButton(
          icon: Icon(
            isVisible ? Icons.visibility : Icons.visibility_off,
            color: isVisible ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.primary,
          ),
          onPressed: () {
            setState(
              () {
                isVisible = !isVisible;
              },
            );
          },
        ),
        label: Text(
          widget.label,
        ),
        alignLabelWithHint: true,
      ),
    );
  }
}
