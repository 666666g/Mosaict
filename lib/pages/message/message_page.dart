/*
 * @Author: error: error: git config user.name & please set dead value or install git && error: git config user.email & please set dead value or install git & please set dead value or install git
 * @Date: 2024-12-29 16:35:10
 * @LastEditors: error: error: git config user.name & please set dead value or install git && error: git config user.email & please set dead value or install git & please set dead value or install git
 * @LastEditTime: 2025-01-01 15:53:02
 * @FilePath: \Mosaic-main1\lib\pages\message\message_page.dart
 * @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
 */
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:pilipala/utils/storage.dart';
import 'package:pilipala/utils/utils.dart';
import '../../chat_page.dart';
import 'controller.dart';

class MessagePage extends StatefulWidget {
  @override
  _MessagePageState createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  final Box userInfoCache = GStrorage.userInfo;
  var userInfo;
  final MessageController _messageController = Get.put(MessageController());
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    userInfo = userInfoCache.get('userInfoCache');
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      _messageController.onLoad();
    }
  }

  String _truncateMessage(String text) {
    if (text.length <= 20) {
      return text;
    }
    return '${text.substring(0, 20)}...';
  }

  Widget _buildListItem(BuildContext context, dynamic sessionItem) {
    final content = sessionItem.lastMsg.content;
    final msgStatus = sessionItem.lastMsg.msgStatus;
    final int msgType = sessionItem.lastMsg.msgType;
    String faceUrl = sessionItem.accountInfo?.face ?? '';
    String name = sessionItem.accountInfo?.name ?? '客服消息';
    String time = DateTime.fromMillisecondsSinceEpoch(sessionItem.lastMsg.timestamp * 1000)
        .toString()
        .substring(11, 16);
    String message = msgType == 1
        ? content['content']
        : msgType == 2
            ? '[图片]'
            : msgType == 5
                ? '[视频]'
                : msgType == 12
                    ? '[撤回]'
                    : '[未知消息类型]';

    return Container(
      height: 75, // 固定高度
      child: ListTile(
        leading: CircleAvatar(
          child: ClipOval(
            child: CachedNetworkImage(
              imageUrl: faceUrl,
              placeholder: (context, url) => CircularProgressIndicator(),
              errorWidget: (context, url, error) => Icon(Icons.error),
              fit: BoxFit.cover,
            ),
          ),
        ),
        title: Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          _truncateMessage(message),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(time, style: TextStyle(color: Colors.grey)),
            if (sessionItem.unreadCount > 0)
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: CircleAvatar(
                  radius: 10,
                  backgroundColor: Colors.red,
                  child: Text(
                    sessionItem.unreadCount.toString(),
                    style: TextStyle(fontSize: 10, color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
        onTap: () {
          sessionItem.unreadCount = 0;
          _messageController.sessionList.refresh();
          Get.toNamed(
            '/whisperDetail',
            parameters: {
              'talkerId': sessionItem.talkerId.toString(),
              'name': name,
              'face': faceUrl,
              'mid': (sessionItem.accountInfo?.mid ?? 0).toString(),
              'heroTag': 'whisper_${sessionItem.accountInfo?.mid ?? 0}',
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFEFF4FE),
        elevation: 0,
        title: Row(
          children: [
            CircleAvatar(
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl: userInfo?.face ?? "https://i0.hdslb.com/bfs/face/member/noface.jpg",
                  placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                  fit: BoxFit.cover,
                ),
              ),
              radius: 20,
            ),
            SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userInfo?.uname ?? "未登录",
                  style: TextStyle(color: Colors.black, fontSize: 16)
                ),
                Text("现在游戏中 >", style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 13),
            child: SizedBox(
              height: 35,
              child: GestureDetector(
                onTap: () => Get.toNamed('/search'),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Icon(Icons.search, color: Colors.grey, size: 20),
                          SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '搜索',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Icon(Icons.more_horiz, color: Colors.grey, size: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: const Color(0xFFF5F5F5),
              child: Obx(
                () => RefreshIndicator(
                  onRefresh: () => _messageController.onRefresh(),
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: _messageController.sessionList.length + 1,
                    itemBuilder: (context, index) {
                      if (index == _messageController.sessionList.length) {
                        return _messageController.isLoading
                            ? Container(
                                padding: EdgeInsets.symmetric(vertical: 15),
                                alignment: Alignment.center,
                                child: CircularProgressIndicator(),
                              )
                            : Container();
                      }
                      return _buildListItem(
                        context,
                        _messageController.sessionList[index],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 