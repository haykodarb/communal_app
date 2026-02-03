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
  filledIcon,
  tonalIcon,
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
    this.expand = true,
  });

  final RxBool? loading;
  final RxBool? disabled;
  final void Function(BuildContext) onPressed;
  final Widget child;
  final ButtonStyle? style;
  final CommonButtonType type;
  final bool expand;

  Widget _buildButton(
    void Function()? callback,
    CommonButtonType type,
    BuildContext context,
  ) {
    ButtonStyle? finalStyle = style;
    if (expand) {
      finalStyle = style?.copyWith(
            fixedSize: const WidgetStatePropertyAll(
              Size.fromHeight(60),
            ),
          ) ??
          FilledButton.styleFrom(
            fixedSize: const Size.fromHeight(60),
          );
    }

    const double loaderSize = 30;

    switch (type) {
      case CommonButtonType.filled:
        return FilledButton(
          onPressed: callback,
          style: finalStyle,
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
          style: finalStyle?.copyWith(
                backgroundColor: WidgetStatePropertyAll(
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
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
                    .withValues(alpha: 0.15),
              ),
          child: CommonLoadingBody(
            loading: loading?.value ?? false,
            color: Theme.of(context).colorScheme.primary,
            size: loaderSize,
            child: child,
          ),
        );
      case CommonButtonType.elevated:
        return ElevatedButton(
          onPressed: callback,
          style: finalStyle,
          child: CommonLoadingBody(
            loading: loading?.value ?? false,
            color: Theme.of(context).colorScheme.onPrimary,
            size: loaderSize,
            child: child,
          ),
        );

      case CommonButtonType.outlined:
        return OutlinedButton(
          onPressed: callback,
          style: finalStyle,
          child: CommonLoadingBody(
            loading: loading?.value ?? false,
            size: loaderSize,
            child: child,
          ),
        );
      case CommonButtonType.outlinedIcon:
        return CommonLoadingBody(
          loading: loading?.value ?? false,
          size: loaderSize,
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
          size: loaderSize,
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
      case CommonButtonType.tonalIcon:
        return CommonLoadingBody(
          loading: loading?.value ?? false,
          size: loaderSize,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
            ),
            child: IconButton(
              onPressed: callback,
              color: Theme.of(context).colorScheme.primary,
              padding: EdgeInsets.zero,
              icon: child,
            ),
          ),
        );
      case CommonButtonType.text:
        return TextButton(
          onPressed: callback,
          style: finalStyle,
          child: CommonLoadingBody(
            loading: loading?.value ?? false,
            size: loaderSize,
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
