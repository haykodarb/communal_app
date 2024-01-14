import 'package:communal/models/profile.dart';
import 'package:communal/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CommonUsernameButton extends StatelessWidget {
  const CommonUsernameButton({super.key, required this.user});

  final Profile user;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        Get.toNamed(
          RouteNames.profileOtherPage,
          arguments: {
            'user': user,
          },
        );
      },
      child: Text(
        user.username,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
    ;
  }
}
