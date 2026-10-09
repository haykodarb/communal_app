import 'package:flutter/material.dart';

/// Given to GetMaterialApp, so a toast can be shown from a controller after
/// its page has already been popped.
final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

/// One-shot feedback after an action (saved, deleted, requested...): a pill
/// at the bottom centre that goes away on its own or when tapped. Errors are
/// red and stay up a little longer. A new toast replaces the one showing.
class CommonToast {
  static void show(String message, {bool error = false}) {
    final ScaffoldMessengerState? messenger =
        rootScaffoldMessengerKey.currentState;
    if (messenger == null) return;

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        // The SnackBar itself is invisible: the messenger sits above the
        // app's Theme, so the pill is drawn by the content, which is built
        // inside it.
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          elevation: 0,
          padding: EdgeInsets.zero,
          duration: Duration(milliseconds: error ? 4500 : 3000),
          content: Builder(
            builder: (context) {
              final ColorScheme colors = Theme.of(context).colorScheme;

              return Center(
                child: GestureDetector(
                  onTap: messenger.hideCurrentSnackBar,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 420),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: error ? colors.error : colors.onSurface,
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: [
                        BoxShadow(
                          color: colors.shadow.withValues(alpha: 0.6),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: error ? colors.onPrimary : colors.surface,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
  }
}
