import 'package:communal/models/profile.dart';
import 'package:communal/presentation/common/common_circular_avatar.dart';
import 'package:flutter/material.dart';

/// A user in a list (search results, friends): avatar and name opening the
/// profile, plus optional trailing buttons.
class CommonUserCard extends StatelessWidget {
  const CommonUserCard({
    super.key,
    required this.profile,
    this.actions = const [],
  });

  final Profile profile;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => profile.goToProfilePage(context),
        enableFeedback: false,
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        child: SizedBox(
          height: 60,
          child: Padding(
            padding: const EdgeInsets.only(left: 15, right: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CommonCircularAvatar(
                  profile: profile,
                  radius: 20,
                  clickable: true,
                ),
                const VerticalDivider(width: 10),
                Expanded(
                  child: Text(
                    profile.username,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                for (final Widget action in actions) ...[
                  const VerticalDivider(width: 5),
                  action,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
