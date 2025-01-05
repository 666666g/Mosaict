/*
 * @Author: error: error: git config user.name & please set dead value or install git && error: git config user.email & please set dead value or install git & please set dead value or install git
 * @Date: 2024-12-15 06:36:52
 * @LastEditors: error: error: git config user.name & please set dead value or install git && error: git config user.email & please set dead value or install git & please set dead value or install git
 * @LastEditTime: 2025-01-01 13:27:51
 * @FilePath: \Mosaic-main1\lib\pages\fan\view.dart
 * @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
 */
import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pilipala/common/widgets/http_error.dart';
import 'package:pilipala/common/widgets/no_data.dart';
import 'package:pilipala/models/fans/result.dart';

import 'controller.dart';
import 'widgets/fan_item.dart';

class FansPage extends StatefulWidget {
  const FansPage({super.key});

  @override
  State<FansPage> createState() => _FansPageState();
}

class _FansPageState extends State<FansPage> {
  late FansController _fansController;
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    String mid = Get.parameters['mid'] ?? '-1';
    _fansController = Get.find<FansController>(tag: mid);
    _fansController.queryFans('init');
    scrollController.addListener(
      () async {
        if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 200) {
          EasyThrottle.throttle('follow', const Duration(seconds: 1), () {
            _fansController.queryFans('onLoad');
          });
        }
      },
    );
  }

  @override
  void dispose() {
    scrollController.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => await _fansController.queryFans('init'),
      child: Obx(
        () => _fansController.fansList.isEmpty
            ? const CustomScrollView(
                slivers: [NoData()],
              )
            : ListView.builder(
                controller: scrollController,
                itemCount: _fansController.fansList.length + 1,
                itemBuilder: (BuildContext context, int index) {
                  if (index == _fansController.fansList.length) {
                    return Container(
                      height: MediaQuery.of(context).padding.bottom + 60,
                      padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).padding.bottom),
                      child: Center(
                        child: Text(
                          _fansController.loadingText.value,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.outline,
                              fontSize: 13),
                        ),
                      ),
                    );
                  } else {
                    return fanItem(item: _fansController.fansList[index]);
                  }
                },
              ),
      ),
    );
  }
}
