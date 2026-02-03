import 'package:atlas_icons/atlas_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CommonSearchBar extends StatelessWidget {
  const CommonSearchBar({
    super.key,
    required this.searchCallback,
    required this.focusNode,
    this.filterCallback,
  });

  final Function(String) searchCallback;
  final Function()? filterCallback;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: TextField(
              expands: true,
              onChanged: searchCallback,
              focusNode: focusNode,
              minLines: null,
              maxLines: null,
              onTapOutside: (event) {
                focusNode.unfocus();
              },
              cursorColor: Theme.of(context).colorScheme.onSurface,
              textAlignVertical: TextAlignVertical.center,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                fillColor: Theme.of(context).colorScheme.surfaceContainer,
                contentPadding: EdgeInsets.zero,
                isCollapsed: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: Icon(
                  Atlas.magnifying_glass,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                labelStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 14,
                ),
                label: Text(
                  '${'Search'.tr}...',
                  textAlign: TextAlign.center,
                ),
                floatingLabelBehavior: FloatingLabelBehavior.never,
              ),
            ),
          ),
          Visibility(
            visible: filterCallback != null,
            child: Row(
              children: [
                const VerticalDivider(width: 5),
                SizedBox(
                  width: 50,
                  height: 50,
                  child: IconButton(
                    onPressed: filterCallback ?? () {},
                    iconSize: 20,
                    style: IconButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).colorScheme.surfaceContainer,
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: Icon(
                      Atlas.horizontal_sliders_dots,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
