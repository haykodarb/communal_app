import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CommunitySpecificBookController extends GetxController {
  CommunitySpecificBookController();
}

class CommunitySpecificBookPage extends GetView<CommunitySpecificBookController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('CommunitySpecificBookPage')),
        body: SafeArea(child: Text('CommunitySpecificBookController')));
  }
}
