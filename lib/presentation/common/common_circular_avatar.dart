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

    bytes = await UsersBackend.getProfileAvatar(profile, height: 120);

    if (bytes != null && bytes!.isNotEmpty) {
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
    this.color,
  });

  final Image? image;
  final Profile profile;
  final double radius;
  final bool clickable;
  final Color? color;

  Widget _imageAvatar(CommonCircularAvatarController controller) {
    return Obx(
      () {
        if (controller.loading.value) {
          return Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
            ),
            clipBehavior: Clip.hardEdge,
            height: radius * 2,
            width: radius * 2,
            child: const CommonLoadingImage(),
          );
        }

        if (image != null) {
          return Container(
            clipBehavior: Clip.hardEdge,
            decoration: const BoxDecoration(
              color: Colors.transparent,
              shape: BoxShape.circle,
            ),
            height: radius * 2,
            width: radius * 2,
            child: Image(
              image: image!.image,
            ),
          );
        }

        final bool hasData =
            controller.bytes != null && controller.bytes!.isNotEmpty;

        if (!hasData) return _iconAvatar();

        return AnimatedOpacity(
          opacity: hasData ? 1 : 0,
          duration: const Duration(milliseconds: 200),
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: const BoxDecoration(
              color: Colors.transparent,
              shape: BoxShape.circle,
            ),
            height: radius * 2,
            width: radius * 2,
            child: Image.memory(
              controller.bytes!,
              isAntiAlias: true,
              gaplessPlayback: true,
            ),
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
          backgroundColor: color ?? Theme.of(context).colorScheme.primary,
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
