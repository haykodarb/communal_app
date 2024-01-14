import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CommonAsyncTextFieldController extends GetxController {
  Timer? debounce;
  RxBool isValidating = false.obs;
  RxBool isWaiting = false.obs;
  RxnString asyncValidationMessage = RxnString();
}

class CommonAsyncTextField extends StatelessWidget {
  const CommonAsyncTextField({
    super.key,
    required this.callback,
    required this.label,
    required this.asyncValidator,
    required this.syncValidator,
    required this.duration,
    this.minLines = 1,
    this.maxLines = 1,
    this.maxLength = 60,
    this.initialValue,
  });

  final void Function(String) callback;
  final Future<String?> Function(String?) asyncValidator;
  final String? Function(String?) syncValidator;
  final Duration duration;
  final int minLines;
  final int maxLines;
  final int? maxLength;
  final String? initialValue;
  final String label;

  @override
  Widget build(BuildContext context) {
    final TextEditingController textController = TextEditingController(text: initialValue);

    return GetBuilder<CommonAsyncTextFieldController>(
      init: CommonAsyncTextFieldController(),
      builder: (controller) {
        return Obx(
          () {
            final bool isValidating = controller.isValidating.value;
            final String? asyncValidationMessage = controller.asyncValidationMessage.value;

            return TextFormField(
              validator: (String? value) {
                String? syncValidationMessage = syncValidator(value);

                if (syncValidationMessage != null) return syncValidationMessage;

                if (isValidating) {
                  return 'Checking username...';
                }

                if (asyncValidationMessage != null) {
                  return asyncValidationMessage;
                }

                return null;
              },
              autovalidateMode: AutovalidateMode.onUserInteraction,
              cursorColor: Theme.of(context).colorScheme.primary,
              onChanged: (String value) {
                callback(value);

                if (value.isEmpty) {
                  controller.asyncValidationMessage.value = null;
                }

                controller.isValidating.value = true;

                if (controller.debounce?.isActive ?? false) {
                  controller.debounce?.cancel();
                }

                controller.isWaiting.value = true;

                controller.debounce = Timer(
                  duration,
                  () async {
                    controller.isWaiting.value = false;

                    controller.isValidating.value = true;
                    controller.asyncValidationMessage.value = await asyncValidator(value);
                    controller.isValidating.value = false;
                  },
                );
              },
              controller: textController,
              minLines: minLines,
              maxLines: maxLines,
              maxLength: maxLength,
              decoration: InputDecoration(
                counter: const SizedBox.shrink(),
                suffixIcon: Visibility(
                  visible: isValidating,
                  child: Container(
                    alignment: Alignment.center,
                    height: 20,
                    width: 20,
                    child: const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                ),
                label: Text(
                  label,
                ),
                alignLabelWithHint: true,
              ),
            );
          },
        );
      },
    );
  }
}
