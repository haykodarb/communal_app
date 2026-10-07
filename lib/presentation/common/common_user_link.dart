import 'package:communal/models/profile.dart';
import 'package:communal/presentation/common/common_circular_avatar.dart';
import 'package:communal/routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// A person inline: their avatar and username, linking to their profile (your
/// own goes to My Profile). Hovering draws a 1px underline under the name from
/// left to right; it shrinks back when the pointer leaves. There's no
/// underline otherwise. The font size comes from [fontSize].
class CommonUserLink extends StatefulWidget {
  const CommonUserLink({
    super.key,
    required this.profile,
    this.avatarSize = 20,
    this.fontSize = 14,
    this.showAvatar = true,
  });

  final Profile profile;
  final double avatarSize;
  final double fontSize;
  final bool showAvatar;

  @override
  State<CommonUserLink> createState() => _CommonUserLinkState();
}

class _CommonUserLinkState extends State<CommonUserLink> {
  bool _hovered = false;

  void _open() {
    context.push(
      widget.profile.isCurrentUser
          ? RouteNames.profileOwnPage
          : RouteNames.profileOtherPage
              .replaceFirst(':userId', widget.profile.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color color = Theme.of(context).colorScheme.primary;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _open,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.showAvatar) ...[
              // A fixed box, so the link can sit inside intrinsic layouts
              // (the default avatar uses a LayoutBuilder).
              SizedBox.square(
                dimension: widget.avatarSize,
                child: CommonCircularAvatar(
                  profile: widget.profile,
                  radius: widget.avatarSize / 2,
                ),
              ),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Text(
                      widget.profile.username,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: widget.fontSize,
                        fontWeight: FontWeight.w500,
                        color: color,
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: -2,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: AnimatedFractionallySizedBox(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOutCubic,
                          widthFactor: _hovered ? 1 : 0,
                          child: Container(height: 1, color: color),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
