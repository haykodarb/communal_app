import 'dart:async';

import 'package:flutter/material.dart';

final GlobalKey<_CommonToastHostState> _hostKey =
    GlobalKey<_CommonToastHostState>();

/// One-shot feedback after an action (saved, deleted, requested...): a pill
/// at the bottom centre that goes away on its own or when tapped. Errors are
/// red and stay up a little longer. A new toast replaces the one showing.
class CommonToast {
  static void show(String message, {bool error = false}) {
    _hostKey.currentState?.show(message, error: error);
  }
}

/// Wraps the whole app (from GetMaterialApp's builder) so a toast can be shown
/// from a controller after its page has already been popped. It fades and
/// slides in from the bottom, and back out the same way.
class CommonToastHost extends StatefulWidget {
  CommonToastHost({required this.child}) : super(key: _hostKey);

  final Widget child;

  @override
  State<CommonToastHost> createState() => _CommonToastHostState();
}

class _CommonToastHostState extends State<CommonToastHost>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
    // A short fade is what tells the user the toast came and went, so it
    // plays in full even when the system asks for reduced motion (which
    // would otherwise cut it to a few milliseconds).
    animationBehavior: AnimationBehavior.preserve,
  );
  late final Animation<double> _curve = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
    reverseCurve: Curves.easeInCubic,
  );

  String _message = '';
  bool _error = false;
  Timer? _timer;

  void show(String message, {required bool error}) {
    setState(() {
      _message = message;
      _error = error;
    });
    _controller.forward();
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: error ? 4500 : 3000), hide);
  }

  void hide() {
    _timer?.cancel();
    _controller.reverse();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Stack(
      children: [
        widget.child,
        Positioned(
          left: 16,
          right: 16,
          bottom: MediaQuery.viewPaddingOf(context).bottom + 24,
          child: AnimatedBuilder(
            animation: _curve,
            builder: (context, child) {
              if (_controller.isDismissed) return const SizedBox.shrink();

              return IgnorePointer(
                ignoring: _controller.status == AnimationStatus.reverse,
                child: Opacity(
                  opacity: _curve.value,
                  child: Transform.translate(
                    offset: Offset(0, 24 * (1 - _curve.value)),
                    child: child,
                  ),
                ),
              );
            },
            child: Material(
              type: MaterialType.transparency,
              child: Center(
                child: GestureDetector(
                  onTap: hide,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 420),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: _error ? colors.error : colors.onSurface,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      _message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _error ? colors.onPrimary : colors.surface,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
