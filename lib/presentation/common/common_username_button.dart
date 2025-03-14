import 'package:communal/models/profile.dart';
import 'package:communal/routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CommonUsernameButton extends StatelessWidget {
  const CommonUsernameButton({super.key, required this.user});

  final Profile user;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: user.isCurrentUser
          ? null
          : () {
              context.push(
                RouteNames.profileOtherPage.replaceFirst(':userId', user.id),
              );
            },
      child: Text(
        user.username,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
