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
    this.inheritedController,
  });

  final void Function(String) callback;
  final String? Function(String?) validator;
  final int minLines;
  final int maxLines;
  final int? maxLength;
  final String? initialValue;
  final TextEditingController? inheritedController;
  final String label;

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = inheritedController ?? TextEditingController(text: initialValue);

    return TextFormField(
      validator: validator,
      cursorColor: Theme.of(context).colorScheme.primary,
      onChanged: callback,
      controller: controller,
      style: TextStyle(fontSize: 14),
      minLines: minLines,
      maxLines: maxLines,
      maxLength: maxLength,
      decoration: InputDecoration(
        counter: const SizedBox.shrink(),
        label: Text(label),
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
      style: TextStyle(fontSize: 14),
      decoration: InputDecoration(
        counter: const SizedBox.shrink(),
        suffixIcon: Padding(
          padding: const EdgeInsets.only(right: 10),
          child: IconButton(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            icon: Icon(
              isVisible ? Icons.visibility : Icons.visibility_off,
              size: 26,
              color: isVisible ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            onPressed: () {
              setState(
                () {
                  isVisible = !isVisible;
                },
              );
            },
          ),
        ),
        label: Text(
          widget.label,
        ),
        alignLabelWithHint: true,
      ),
    );
  }
}
