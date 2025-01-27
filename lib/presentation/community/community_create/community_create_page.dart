import 'package:atlas_icons/atlas_icons.dart';
import 'package:communal/presentation/common/common_loading_body.dart';
import 'package:communal/presentation/common/common_responsive_page.dart';
import 'package:communal/presentation/common/common_text_field.dart';
import 'package:communal/presentation/community/community_create/community_create_controller.dart';
import 'package:communal/responsive.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class CommunityCreatePage extends StatelessWidget {
  const CommunityCreatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: CommunityCreateController(),
      builder: (controller) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: Responsive.isMobile(context) ? const Text('Create Community') : null,
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
            child: Form(
              key: controller.formKey,
              child: Column(
                children: [
                  Container(
                    width: 300,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Stack(
                        children: [
                          SizedBox(
                            width: double.maxFinite,
                            height: double.maxFinite,
                            child: Obx(
                              () {
                                if (controller.selectedBytes.value != null) {
                                  return Image.memory(
                                    controller.selectedBytes.value!,
                                    fit: BoxFit.cover,
                                  );
                                } else {
                                  return Card(
                                    margin: EdgeInsets.zero,
                                    color: Theme.of(context).colorScheme.surfaceContainer,
                                    child: const Center(
                                      child: Text(
                                        'No\nimage',
                                        style: TextStyle(fontSize: 18),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                          Container(
                            width: double.maxFinite,
                            padding: const EdgeInsets.only(bottom: 20),
                            alignment: Alignment.bottomCenter,
                            child: Obx(
                              () {
                                final bool fileSelected = controller.selectedBytes.value != null;

                                final Color buttonBackground = fileSelected
                                    ? Theme.of(context).colorScheme.surfaceContainer
                                    : Theme.of(context).colorScheme.primary;

                                final Color iconColor = fileSelected
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.onPrimary;

                                final Border? buttonBorder = fileSelected
                                    ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2)
                                    : null;

                                if (kIsWeb) {
                                  return InkWell(
                                    onTap: () => controller.takePicture(
                                      ImageSource.gallery,
                                      context,
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: buttonBorder,
                                        borderRadius: BorderRadius.circular(10),
                                        color: buttonBackground,
                                      ),
                                      padding: const EdgeInsets.all(13),
                                      child: Icon(
                                        Atlas.image_gallery,
                                        color: iconColor,
                                        size: 24,
                                      ),
                                    ),
                                  );
                                }

                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    InkWell(
                                      onTap: () => controller.takePicture(ImageSource.camera, context),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border: buttonBorder,
                                          borderRadius: BorderRadius.circular(10),
                                          color: buttonBackground,
                                        ),
                                        padding: const EdgeInsets.all(13),
                                        child: Icon(
                                          Atlas.camera,
                                          weight: 400,
                                          color: iconColor,
                                          size: 24,
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () => controller.takePicture(ImageSource.gallery, context),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border: buttonBorder,
                                          borderRadius: BorderRadius.circular(10),
                                          color: buttonBackground,
                                        ),
                                        padding: const EdgeInsets.all(13),
                                        child: Icon(
                                          Atlas.image_gallery,
                                          color: iconColor,
                                          size: 24,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(height: 20),
                  Form(
                    child: Column(
                      children: [
                        CommonTextField(
                          callback: controller.onNameChange,
                          label: 'Name',
                          submitCallback: (_) => controller.onSubmit(context),
                          validator: (value) => controller.stringValidator(
                            value,
                            4,
                            false,
                          ),
                        ),
                      ],
                    ),
                  ),
                  CommonTextField(
                    callback: controller.onDescriptorChange,
                    label: 'Description (Optional)',
                    submitCallback: (_) => controller.onSubmit(context),
                    minLines: 5,
                    maxLines: 10,
                    validator: (value) => controller.stringValidator(
                      value,
                      4,
                      true,
                    ),
                  ),
                  const Divider(height: 20),
                  SizedBox(
                    height: 70,
                    child: Obx(
                      () => CommonLoadingBody(
                        loading: controller.loading.value,
                        size: 40,
                        child: ElevatedButton(
                          onPressed: () => controller.onSubmit(context),
                          child: const Text(
                            'Create',
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
