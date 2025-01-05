import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:pilipala/http/fan.dart';
import 'package:pilipala/models/fans/result.dart';
import 'package:pilipala/utils/storage.dart';

class FansController extends GetxController {
  Box userInfoCache = GStrorage.userInfo;
  int pn = 1;
  int ps = 20;
  int total = 0;
  RxList<FansItemModel> fansList = <FansItemModel>[].obs;
  RxInt mid = (-1).obs;
  RxString name = ''.obs;
  var userInfo;
  RxString loadingText = '加载中...'.obs;
  RxBool userLogin = false.obs;
  RxBool isOwner = false.obs;

  @override
  void onInit() {
    super.onInit();
    userInfo = userInfoCache.get('userInfoCache');
    userLogin.value = userInfo != null;
    
    mid.value = int.parse(Get.parameters['mid'] ?? (userInfo?.mid?.toString() ?? '-1'));
    name.value = Get.parameters['name'] ?? userInfo?.uname ?? '';
    
    isOwner.value = userInfo != null && mid.value == userInfo.mid;
  }

  Future queryFans(type) async {
    if (!userLogin.value) {
      return {'status': false, 'msg': '请先登录'};
    }
    if (type == 'init') {
      pn = 1;
      loadingText.value = '加载中...';
      fansList.clear();
    }
    if (loadingText.value == '没有更多了') {
      return;
    }
    var res = await FanHttp.fans(
      vmid: mid.value,
      pn: pn,
      ps: ps,
      orderType: 'attention',
    );
    if (res['status']) {
      if (type == 'init') {
        fansList.value = res['data'].list;
        total = res['data'].total;
      } else if (type == 'onLoad') {
        fansList.addAll(res['data'].list);
      }
      if ((pn == 1 && total < ps) || res['data'].list.isEmpty) {
        loadingText.value = '没有更多了';
      }
      pn += 1;
    } else {
      SmartDialog.showToast(res['msg']);
    }
    return res;
  }
}
