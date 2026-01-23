import 'dart:typed_data';

import 'package:communal/backend/users_backend.dart';
import 'package:communal/models/profile.dart';
import 'package:communal/presentation/common/common_keepalive_wrapper.dart';
import 'package:communal/presentation/common/common_loading_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class CommonCircularAvatarController extends GetxController {
  CommonCircularAvatarController({
    required this.profile,
  });

  final Profile profile;
  Uint8List? bytes;

  final RxBool loading = true.obs;

  @override
  Future<void> onInit() async {
    super.onInit();

    loading.value = true;
    print('Getting profile avatar for ${profile.username}');
    bytes = await UsersBackend.getProfileAvatar(profile, height: 120);
    if (bytes!.isNotEmpty) {
      loading.value = false;
    }
  }
}

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

  Widget _imageAvatar(CommonCircularAvatarController controller) {
    return Obx(
      () {
        if (controller.loading.value) return const CommonLoadingImage();

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

        final bool hasData =
            controller.bytes != null && controller.bytes!.isNotEmpty;

        if (!hasData) return _iconAvatar();

        return AnimatedOpacity(
          opacity: hasData ? 1 : 0,
          duration: const Duration(milliseconds: 200),
          child: Container(
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              color: Colors.transparent,
              image: hasData
                  ? DecorationImage(
                      fit: BoxFit.cover,
                      image: Image.memory(
                        controller.bytes!,
                        fit: BoxFit.fitWidth,
                        gaplessPlayback: true,
                      ).image,
                    )
                  : null,
              shape: BoxShape.circle,
            ),
            height: radius * 2,
            width: radius * 2,
          ),
        );
      },
    );
  }

  Widget _iconAvatar() {
    if (profile.id.isEmpty) return const SizedBox.shrink();

    int sum = 0;
    for (var i = 0; i < profile.username.length && i <= 5; i++) {
      sum += profile.username.codeUnitAt(i);
    }

    int icon_index = sum % 6;

    return Builder(
      builder: (context) {
        return CircleAvatar(
          radius: radius,
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Container(
                padding: EdgeInsets.all(constraints.maxWidth * 0.175),
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SvgPicture.asset(
                    'assets/default_avatars/$icon_index.svg',
                    colorFilter: ColorFilter.mode(
                      Theme.of(context).colorScheme.surfaceContainer,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      tag: profile.avatar_path,
      init: CommonCircularAvatarController(profile: profile),
      builder: (controller) {
        return InkWell(
          onTap: clickable
              ? () {
                  profile.goToProfilePage(context);
                }
              : null,
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: (profile.avatar_path == null && image == null)
                ? (_iconAvatar())
                : CommonKeepaliveWrapper(child: _imageAvatar(controller)),
          ),
        );
      },
    );
  }
}
