import 'package:crop_image/crop_image.dart';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class CommonImageCropper extends StatelessWidget {
  const CommonImageCropper({
    super.key,
    required this.image,
    required this.aspectRatio,
  });

  final Image image;
  final double aspectRatio;

  Future<Uint8List?> open(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: build,
    );
  }

  @override
  Widget build(BuildContext context) {
    final CropController cropController = CropController(
      aspectRatio: aspectRatio,
    );
    final deviceHeight = MediaQuery.of(context).size.height;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
        clipBehavior: Clip.hardEdge,
        constraints: BoxConstraints.loose(Size(600, deviceHeight * 0.75)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: CropImage(
                image: image,
                controller: cropController,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              height: 100,
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        context.pop();
                      },
                      child: const Text('Cancel'),
                    ),
                  ),
                  const VerticalDivider(width: 20),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        ui.Image bitmap = await cropController.croppedBitmap();

                        final data = await bitmap.toByteData(
                          format: ui.ImageByteFormat.png,
                        );

                        if (!context.mounted) return;
                        if (data == null) {
                          context.pop();
                          return;
                        }

                        final Uint8List bytes = data.buffer.asUint8List();
                        context.pop(bytes);
                      },
                      child: const Text('Done'),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
