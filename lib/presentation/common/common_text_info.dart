import 'package:flutter/material.dart';

class CommonTextInfo extends StatelessWidget {
  const CommonTextInfo({
    super.key,
    required this.label,
    required this.text,
    required this.size,
  });

  final String label;
  final String text;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.secondary,
            fontSize: size,
          ),
        ),
        Text(
          text,
          style: TextStyle(
            fontSize: size,
          ),
        ),
      ],
    );
  }
}
