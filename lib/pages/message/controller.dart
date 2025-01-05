import 'package:get/get.dart';
import 'package:pilipala/http/msg.dart';
import 'package:pilipala/models/msg/account.dart';
import 'package:pilipala/models/msg/session.dart';

class MessageController extends GetxController {
  RxList<SessionList> sessionList = <SessionList>[].obs;
  RxList<AccountListModel> accountList = <AccountListModel>[].obs;
  bool isLoading = false;

  @override
  void onInit() {
    super.onInit();
    querySessionList('init');
  }

  Future querySessionList(String type) async {
    if (isLoading) return;
    isLoading = true;
    var res = await MsgHttp.sessionList(
        endTs: type == 'onLoad' && sessionList.isNotEmpty ? sessionList.last.sessionTs : null);
    if (res['status'] && res['data']?.sessionList != null) {
      // 获取用户信息
      await queryAccountList(res['data'].sessionList);
      // 创建一个 Map 用于快速查找 accountInfo
      Map<int, AccountListModel> accountMap = {};
      for (var account in accountList) {
        accountMap[account.mid!] = account;
      }

      // 遍历 sessionList，通过 mid 查找并赋值 accountInfo
      for (var i in res['data'].sessionList) {
        var accountInfo = accountMap[i.talkerId];
        if (accountInfo != null) {
          i.accountInfo = accountInfo;
        }
        if (i.talkerId == 844424930131966) {
          i.accountInfo = AccountListModel(
            name: 'UP主小助手',
            face: 'https://message.biliimg.com/bfs/im/489a63efadfb202366c2f88853d2217b5ddc7a13.png',
          );
        }
      }

      if (type == 'onLoad' && res['data'].sessionList.isNotEmpty) {
        sessionList.addAll(res['data'].sessionList);
      } else {
        sessionList.value = res['data'].sessionList;
      }
    }
    isLoading = false;
    return res;
  }

  Future queryAccountList(sessionList) async {
    List midsList = sessionList.map((e) => e.talkerId!).toList();
    var res = await MsgHttp.accountList(midsList.join(','));
    if (res['status'] && res['data'] != null) {
      accountList.value = res['data'];
    }
    return res;
  }

  Future onLoad() async {
    await querySessionList('onLoad');
  }

  Future onRefresh() async {
    await querySessionList('onRefresh');
  }

  void refreshLastMsg(int talkerId, String content) {
    final SessionList currentItem = sessionList.where((p0) => p0.talkerId == talkerId).first;
    currentItem.lastMsg!.content['content'] = content;
    sessionList.removeWhere((p0) => p0.talkerId == talkerId);
    sessionList.insert(0, currentItem);
    sessionList.refresh();
  }

  void removeSessionMsg(int talkerId) {
    sessionList.removeWhere((p0) => p0.talkerId == talkerId);
    sessionList.refresh();
  }
} 