import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class CommonFilterRow extends StatefulWidget {
  const CommonFilterRow({
    super.key,
    required this.title,
    required this.options,
    required this.onIndexChange,
    this.initialIndex = 0,
  });

  final String title;
  final List<String> options;
  final int initialIndex;
  final void Function(int) onIndexChange;

  @override
  State<CommonFilterRow> createState() => _CommonFilterRowState();
}

class _CommonFilterRowState extends State<CommonFilterRow> {
  int currentIndex = 0;

  @override
  void initState() {
    currentIndex = widget.initialIndex;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Divider(height: 10),
        Wrap(
          spacing: 5,
          runSpacing: 5,
          children: widget.options.mapIndexed(
            (index, string) {
              Color color = Theme.of(context).colorScheme.onSurfaceVariant;
              double borderWidth = 0.5;
              FontWeight fontWeight = FontWeight.w400;

              if (index == currentIndex) {
                color = Theme.of(context).colorScheme.primary;
                borderWidth = 1.5;
                fontWeight = FontWeight.w500;
              }

              return InkWell(
                onTap: () {
                  setState(
                    () {
                      currentIndex = index;
                    },
                  );
                  widget.onIndexChange(index);
                },
                highlightColor: Colors.transparent,
                overlayColor: WidgetStateColor.transparent,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(
                      width: borderWidth,
                      color: color,
                    ),
                  ),
                  child: Text(
                    string,
                    style: TextStyle(
                      fontWeight: fontWeight,
                      fontSize: 14,
                      color: color,
                    ),
                  ),
                ),
              );
            },
          ).toList(),
        ),
      ],
    );
  }
}

class CommonFilterBottomsheet extends StatelessWidget {
  const CommonFilterBottomsheet({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return BottomSheet(
      onClosing: () {},
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      enableDrag: false,
      showDragHandle: false,
      builder: (context) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              children: children,
            ),
          ),
        );
      },
    );
  }
}
