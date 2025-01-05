/*
 * @Author: error: error: git config user.name & please set dead value or install git && error: git config user.email & please set dead value or install git & please set dead value or install git
 * @Date: 2024-12-31 20:17:02
 * @LastEditors: error: error: git config user.name & please set dead value or install git && error: git config user.email & please set dead value or install git & please set dead value or install git
 * @LastEditTime: 2025-01-01 14:43:24
 * @FilePath: \Mosaic-main1\lib\pages\fan\wrapper.dart
 * @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
 */
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:pilipala/utils/route_push.dart';
import 'package:pilipala/utils/storage.dart';
import 'package:pilipala/common/widgets/http_error.dart';
import './view.dart';
import './controller.dart';

class FansPageWrapper extends StatelessWidget {
  FansPageWrapper({super.key});

  final Box userInfoCache = GStrorage.userInfo;

  @override
  Widget build(BuildContext context) {
    var userInfo = userInfoCache.get('userInfoCache');
    String mid = Get.parameters['mid'] ?? (userInfo?.mid?.toString() ?? '-1');
    final FansController fansController = Get.put(FansController(), tag: mid);
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        title: Obx(() => Text(
          fansController.isOwner.value ? '我的粉丝' : '${fansController.name}的粉丝',
          style: Theme.of(context).textTheme.titleMedium,
        )),
      ),
      body: CustomScrollView(
        slivers: [
          if (userInfo == null)
            HttpError(
              errMsg: '请先登录',
              btnText: '去登录',
              fn: () => RoutePush.loginRedirectPush(),
            )
          else
            SliverToBoxAdapter(
              child: FansPage(),
            ),
        ],
      ),
    );
  }
} 