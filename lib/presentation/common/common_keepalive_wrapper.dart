import 'package:flutter/material.dart';

class CommonKeepaliveWrapper extends StatefulWidget {
  const CommonKeepaliveWrapper({super.key, required this.child});

  final Widget child;

  @override
  State<CommonKeepaliveWrapper> createState() => _CommonKeepaliveWrapperState();
}

class _CommonKeepaliveWrapperState extends State<CommonKeepaliveWrapper> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }

  @override
  bool get wantKeepAlive => true;
}
