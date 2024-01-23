import 'package:communal/backend/users_backend.dart';
import 'package:communal/models/profile.dart';
import 'package:communal/presentation/common/common_loading_image.dart';
import 'package:communal/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CommonCircularAvatar extends StatelessWidget {
  const CommonCircularAvatar({
    super.key,
    required this.profile,
    required this.radius,
    this.image,
    this.clickable = false,
  });

  final Image? image;
  final Profile profile;
  final double radius;
  final bool clickable;

  Widget _imageAvatar() {
    return FutureBuilder(
      future: UsersBackend.getProfileAvatar(profile),
      builder: (context, snapshot) {
        if (image != null) {
          return Container(
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              color: Colors.transparent,
              image: DecorationImage(
                fit: BoxFit.cover,
                image: image!.image,
              ),
              shape: BoxShape.circle,
            ),
            height: radius * 2,
            width: radius * 2,
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.transparent,
              shape: BoxShape.circle,
            ),
            clipBehavior: Clip.hardEdge,
            height: radius * 2,
            width: radius * 2,
            child: const ClipOval(
              clipBehavior: Clip.hardEdge,
              child: CommonLoadingImage(),
            ),
          );
        }

        return Container(
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: Colors.transparent,
            image: DecorationImage(
              fit: BoxFit.cover,
              image: Image.memory(
                snapshot.data!,
                fit: BoxFit.fitWidth,
              ).image,
            ),
            shape: BoxShape.circle,
          ),
          height: radius * 2,
          width: radius * 2,
        );
      },
    );
  }

  Widget _textAvatar() {
    return Builder(
      builder: (context) {
        return CircleAvatar(
          radius: radius,
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Container(
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                  padding: EdgeInsets.all(constraints.maxWidth * 0.2),
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: Text(
                      profile.username.isNotEmpty ? profile.username.substring(0, 2).toUpperCase() : '',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: clickable
          ? () {
              Get.toNamed(
                RouteNames.profileOtherPage,
                arguments: {
                  'user': profile,
                },
              );
            }
          : null,
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
        ),
        child: (profile.avatar_path == null && image == null) ? _textAvatar() : _imageAvatar(),
      ),
    );
  }
}
