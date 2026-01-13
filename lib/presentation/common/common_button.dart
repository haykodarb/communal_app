import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'common_loading_body.dart';

enum CommonButtonType { filled, elevated, outlined, text }

class CommonButton extends StatelessWidget {
  const CommonButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.loading,
    this.disabled,
    this.type = CommonButtonType.filled,
  });

  final RxBool? loading;
  final RxBool? disabled;
  final void Function(BuildContext) onPressed;
  final Widget child;
  final CommonButtonType type;

  Widget _buildButton(
    void Function()? callback,
    CommonButtonType type,
    BuildContext context,
  ) {
    switch (type) {
      case CommonButtonType.filled:
        return FilledButton(
          onPressed: callback,
          child: CommonLoadingBody(
            loading: loading?.value ?? false,
            color: Theme.of(context).colorScheme.onPrimary,
            size: 40,
            child: child,
          ),
        );
      case CommonButtonType.elevated:
        return ElevatedButton(
          onPressed: callback,
          child: CommonLoadingBody(
            loading: loading?.value ?? false,
            color: Theme.of(context).colorScheme.onPrimary,
            size: 40,
            child: child,
          ),
        );
      case CommonButtonType.outlined:
        return OutlinedButton(
          onPressed: callback,
          child: CommonLoadingBody(
            loading: loading?.value ?? false,
            size: 40,
            child: child,
          ),
        );
      case CommonButtonType.text:
        return TextButton(
          onPressed: callback,
          child: CommonLoadingBody(
            loading: loading?.value ?? false,
            size: 40,
            child: child,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    callback() => onPressed(context);

    if (loading == null && disabled == null) {
      return _buildButton(callback, type, context);
    }

    return Obx(
      () {
        if (disabled != null && disabled!.value) {
          return _buildButton(null, type, context);
        }

        if (loading != null) {
          return _buildButton(loading!.value ? () {} : callback, type, context);
        }

        return _buildButton(callback, type, context);
      },
    );
  }
}
