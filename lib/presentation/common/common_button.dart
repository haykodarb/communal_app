import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'common_loading_body.dart';

enum CommonButtonType {
  filled,
  tonal,
  elevated,
  outlined,
  text,
  outlinedIcon,
  filledIcon
}

class CommonButton extends StatelessWidget {
  const CommonButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.loading,
    this.disabled,
    this.type = CommonButtonType.filled,
    this.style,
  });

  final RxBool? loading;
  final RxBool? disabled;
  final void Function(BuildContext) onPressed;
  final Widget child;
  final ButtonStyle? style;
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
          style: style,
          child: CommonLoadingBody(
            loading: loading?.value ?? false,
            color: Theme.of(context).colorScheme.onPrimary,
            size: 30,
            child: child,
          ),
        );
      case CommonButtonType.tonal:
        return FilledButton.tonal(
          onPressed: callback,
          style: style?.copyWith(
                backgroundColor: WidgetStatePropertyAll(
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.25),
                ),
                foregroundColor: WidgetStatePropertyAll(
                  Theme.of(context).colorScheme.primary,
                ),
              ) ??
              FilledButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
                backgroundColor: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.25),
              ),
          child: CommonLoadingBody(
            loading: loading?.value ?? false,
            color: Theme.of(context).colorScheme.primary,
            size: 30,
            child: child,
          ),
        );
      case CommonButtonType.elevated:
        return ElevatedButton(
          onPressed: callback,
          style: style,
          child: CommonLoadingBody(
            loading: loading?.value ?? false,
            color: Theme.of(context).colorScheme.onPrimary,
            size: 30,
            child: child,
          ),
        );

      case CommonButtonType.outlined:
        return OutlinedButton(
          onPressed: callback,
          style: style,
          child: CommonLoadingBody(
            loading: loading?.value ?? false,
            size: 30,
            child: child,
          ),
        );
      case CommonButtonType.outlinedIcon:
        return CommonLoadingBody(
          loading: loading?.value ?? false,
          size: 30,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).colorScheme.primary,
                width: 1.5,
              ),
            ),
            child: IconButton(
              onPressed: callback,
              color: Theme.of(context).colorScheme.primary,
              padding: EdgeInsets.zero,
              icon: child,
            ),
          ),
        );
      case CommonButtonType.filledIcon:
        return CommonLoadingBody(
          loading: loading?.value ?? false,
          size: 30,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.primary,
            ),
            child: IconButton(
              onPressed: callback,
              color: Theme.of(context).colorScheme.onPrimary,
              padding: EdgeInsets.zero,
              icon: child,
            ),
          ),
        );
      case CommonButtonType.text:
        return TextButton(
          onPressed: callback,
          style: style,
          child: CommonLoadingBody(
            loading: loading?.value ?? false,
            size: 30,
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
