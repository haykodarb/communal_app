import 'package:flutter/material.dart';

class CommonTextField extends StatefulWidget {
  const CommonTextField({
    Key? key,
    required this.callback,
    required this.label,
    this.isPassword = false,
    required this.validator,
    this.minLines = 1,
    this.maxLines = 1,
    this.maxLength = 60,
  }) : super(key: key);

  final void Function(String) callback;
  final String? Function(String?) validator;
  final int minLines;
  final int maxLines;
  final int? maxLength;
  final String label;
  final bool isPassword;

  @override
  // ignore: library_private_types_in_public_api
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CommonTextField> {
  final TextEditingController controller = TextEditingController();

  bool isVisible = false;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: widget.validator,
      cursorColor: Theme.of(context).colorScheme.primary,
      onChanged: widget.callback,
      controller: controller,
      obscureText: widget.isPassword && !isVisible,
      minLines: widget.minLines,
      maxLines: widget.maxLines,
      maxLength: widget.maxLength,
      decoration: InputDecoration(
        counter: const SizedBox.shrink(),
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  isVisible ? Icons.visibility : Icons.visibility_off,
                  color: isVisible
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.primary,
                ),
                onPressed: () {
                  setState(
                    () {
                      isVisible = !isVisible;
                    },
                  );
                },
              )
            : null,
        label: Text(
          widget.label,
        ),
        alignLabelWithHint: true,
      ),
    );
  }
}
