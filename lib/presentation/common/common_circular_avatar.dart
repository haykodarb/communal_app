import 'package:flutter/material.dart';

class CommonCircularAvatar extends StatelessWidget {
  const CommonCircularAvatar({
    super.key,
    required this.username,
    required this.radius,
  });

  final String username;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).colorScheme.secondary,
          width: 2,
        ),
      ),
      child: CircleAvatar(
        radius: radius,
        backgroundColor: Theme.of(context).colorScheme.background,
        foregroundColor: Theme.of(context).colorScheme.onSecondary,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              username.substring(0, 2).toUpperCase(),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onBackground,
                fontSize: 30,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
