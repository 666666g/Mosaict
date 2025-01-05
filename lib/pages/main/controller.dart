import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/common/dynamic_badge_mode.dart';
import '../../http/common.dart';
import '../message/message_page.dart';
import '../fan/wrapper.dart';
import '../video/video_page.dart';
import '../ai/ai_page.dart';
import '../dynamics/index.dart';

class MainController extends GetxController {
  RxInt selectedIndex = 0.obs;
  final PageController pageController = PageController();
  
  final RxBool userLogin = false.obs;
  final Rx<DynamicBadgeMode> dynamicBadgeType = DynamicBadgeMode.number.obs;
  final StreamController<bool> bottomBarStream = StreamController<bool>.broadcast();
  bool imgPreviewStatus = false;
  
  final List<Widget> pages = <Widget>[
    MessagePage(),
    FansPageWrapper(),
    VideoPageWrapper(),
    AiPage(),
    DynamicsPage(),
  ];

  Future<void> getUnreadDynamic() async {
    if (!userLogin.value) return;
    var res = await CommonHttp.unReadDynamic();
    if (res['status']) {
      var data = res['data'];
      // TODO: 根据需要处理数据
    }
  }

  Color getBottomNavBarColor() {
    return selectedIndex.value == 2 ? Colors.black : const Color(0xFFEEEDF1);
  }

  Color getBottomNavItemColor(int index) {
    if (selectedIndex.value == 2) {
      return index == selectedIndex.value ? Colors.white : Colors.white.withOpacity(0.6);
    } else {
      return index == selectedIndex.value ? Colors.blue : Colors.grey;
    }
  }

  @override
  void onClose() {
    pageController.dispose();
    bottomBarStream.close();
    super.onClose();
  }
}
