/*
 * @Author: error: error: git config user.name & please set dead value or install git && error: git config user.email & please set dead value or install git & please set dead value or install git
 * @Date: 2024-12-15 06:36:52
 * @LastEditors: error: error: git config user.name & please set dead value or install git && error: git config user.email & please set dead value or install git & please set dead value or install git
 * @LastEditTime: 2024-12-31 19:20:48
 * @FilePath: \Mosaic-main1\lib\pages\main\view.dart
 * @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
 */
import 'dart:async';


import 'package:hive/hive.dart';
import 'package:pilipala/models/common/dynamic_badge_mode.dart';
import 'package:pilipala/pages/dynamics/index.dart';
import 'package:pilipala/pages/home/index.dart';
import 'package:pilipala/pages/media/index.dart';
import 'package:pilipala/pages/rank/index.dart';
import 'package:pilipala/utils/event_bus.dart';
import 'package:pilipala/utils/feed_back.dart';
import 'package:pilipala/utils/storage.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import './controller.dart';

class MainApp extends GetView<MainController> {
  MainApp({super.key}) {
    Get.put(MainController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: controller.pageController,
        onPageChanged: (index) {
          controller.selectedIndex.value = index;
        },
        children: controller.pages,
      ),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: controller.getBottomNavBarColor(),
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.message),
              label: "消息",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: "联系人",
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/images/video.png',
                width: 24,
                height: 24,
                color: controller.getBottomNavItemColor(2),
              ),
              label: "短视频",
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/images/ai.png',
                width: 24,
                height: 24,
                color: controller.getBottomNavItemColor(3),
              ),
              label: "AI",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.dynamic_feed),
              label: "动态",
            ),
          ],
          currentIndex: controller.selectedIndex.value,
          selectedItemColor: controller.getBottomNavItemColor(controller.selectedIndex.value),
          unselectedItemColor: controller.selectedIndex.value == 2 ? Colors.white.withOpacity(0.6) : Colors.grey,
          onTap: (index) {
            controller.selectedIndex.value = index;
            controller.pageController.animateToPage(
              index,
              duration: Duration(milliseconds: 300),
              curve: Curves.ease,
            );
          },
        ),
      ),
    );
  }
}
