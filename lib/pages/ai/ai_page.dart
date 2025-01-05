import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class AiPage extends StatefulWidget {
  @override
  _AiPageState createState() => _AiPageState();
}

class _AiPageState extends State<AiPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  final http.Client _client = http.Client();
  final ScrollController _scrollController = ScrollController();

  Timer? _debounce;
  final Map<String, String> _messageCache = {};
  Timer? _typingTimer;

  bool _isSending = false;
  String? _errorMessage;
  Timer? _errorTimer;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  _scrollListener() {
    if (_scrollController.position.atEdge) {
      if (_scrollController.position.pixels == 0) {
        // 滚动到顶部时的操作
      } else {
        // 滚动到底部时的操作
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _client.close();
    _messageController.dispose();
    _errorTimer?.cancel();
    _debounce?.cancel();
    _typingTimer?.cancel();
    super.dispose();
  }

  void _scrollToBottom() {
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  void _debouncedSendMessage() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _sendMessage();
    });
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty || _isSending) return;

    setState(() {
      _isSending = true;
      _errorMessage = null;
      _messages.add({
        "role": "user",
        "content": message,
        "status": "sending",
      });
      _messageController.clear();
    });

    _scrollToBottom();

    try {
      await _sendMessageToApi(message);
    } catch (e) {
      _handleMessageError(message);
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  Future<void> _sendMessageToApi(String message) async {
    final response = await _client.post(
      Uri.parse("https://spark-api-open.xf-yun.com/v1/chat/completions"),
      headers: {
        "Authorization": "Bearer LfxtzgiHjTyGwaEcdGqO:lZHjCRbriZsTJPCyRFzV",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "model": "lite",
        "messages": _messages,
        "stream": true,
      }),
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      await _handleSuccessResponse(response);
    } else {
      throw Exception('API request failed with status: ${response.statusCode}');
    }
  }

  Future<void> _handleSuccessResponse(http.Response response) async {
    String responseBody = utf8.decode(response.bodyBytes);
    String aiResponse = "";

    setState(() {
      _messages.last["status"] = "sent";
      _messages.add({
        "role": "assistant",
        "content": "",
        "status": "receiving"
      });
    });

    int aiMessageIndex = _messages.length - 1;
    String fullResponse = "";

    for (var line in responseBody.split('\n')) {
      if (!line.startsWith("data: ") || line.isEmpty) continue;

      String jsonStr = line.substring(6);
      if (jsonStr.trim() == "[DONE]") break;

      try {
        Map<String, dynamic> jsonChunk = jsonDecode(jsonStr);
        if (jsonChunk.containsKey('choices') && jsonChunk['choices'] is List) {
          String? content = jsonChunk['choices'][0]['delta']['content'];
          if (content != null) {
            fullResponse += content;
            List<String> chars = fullResponse.split('');

            for (int i = aiResponse.length; i < chars.length; i++) {
              await Future.delayed(Duration(milliseconds: 60));
              if (!mounted) return;

              aiResponse = chars.sublist(0, i + 1).join();
              setState(() {
                _messages[aiMessageIndex]["content"] = aiResponse;
              });
              _messageCache[aiMessageIndex.toString()] = aiResponse;
            }
          }
        }
      } catch (e) {
        print("解析 JSON 出错: $e, JSON 字符串: $jsonStr");
      }
    }

    setState(() {
      _messages[aiMessageIndex]["status"] = "sent";
    });
  }

  void _handleMessageError(String originalMessage) {
    setState(() {
      _errorMessage = "消息发送失败，请重试";
      final lastUserMessage = _messages.lastWhere((msg) => msg["role"] == "user");
      lastUserMessage["status"] = "failed";
    });

    _errorTimer?.cancel();
    _errorTimer = Timer(Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _errorMessage = null);
      }
    });
  }

  Future<void> _retryMessage(int index) async {
    final message = _messages[index];
    if (message["status"] != "failed") return;

    setState(() {
      message["status"] = "sending";
      _errorMessage = null;
    });

    try {
      await _sendMessageToApi(message["content"]);
      setState(() => message["status"] = "sent");
    } catch (e) {
      setState(() => message["status"] = "failed");
      _handleMessageError(message["content"]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mosaic'),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          if (_errorMessage != null)
            Container(
              color: Colors.red[100],
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red),
                  SizedBox(width: 8),
                  Text(_errorMessage!, style: TextStyle(color: Colors.red)),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.red),
                    onPressed: () => setState(() => _errorMessage = null),
                  ),
                ],
              ),
            ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return ChatMessage(
                  message: message,
                  onRetry: message["status"] == "failed"
                      ? () => _retryMessage(index)
                      : null,
                );
              },
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        height: 47,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: Offset(0, 2),
              blurRadius: 8,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  enabled: !_isSending,
                  decoration: InputDecoration(
                    hintText: _isSending ? '正在发送...' : '有问题尽管问我',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                    hintStyle: TextStyle(fontSize: 14),
                  ),
                  maxLines: 1,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _debouncedSendMessage(),
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 8),
                child: IconButton(
                  icon: _isSending
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                          ),
                        )
                      : Icon(Icons.send, color: Colors.blue, size: 22),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(
                    minWidth: 35,
                    minHeight: 35,
                  ),
                  onPressed: _isSending ? null : _debouncedSendMessage,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChatMessage extends StatelessWidget {
  final Map<String, dynamic> message;
  final VoidCallback? onRetry;

  const ChatMessage({
    Key? key,
    required this.message,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isSender = message['role'] == 'user';
    return Container(
      margin: EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (!isSender) ...[
            CircleAvatar(
              backgroundImage: NetworkImage('https://mex.us.kg/icons/icon-192x192.png'),
              radius: 12,
            ),
            SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                _buildMessageBubble(context, isSender),
                if (message["status"] == "failed")
                  TextButton.icon(
                    icon: Icon(Icons.refresh, size: 16),
                    label: Text("重试"),
                    onPressed: onRetry,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size(0, 24),
                    ),
                  ),
              ],
            ),
          ),
          if (isSender) ...[
            SizedBox(width: 8),
            _buildStatusIndicator(),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusIndicator() {
    switch (message["status"]) {
      case "sending":
        return SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      case "failed":
        return Icon(Icons.error_outline, color: Colors.red, size: 16);
      case "sent":
        return Icon(Icons.check, color: Colors.green, size: 16);
      default:
        return SizedBox(width: 16);
    }
  }

  Widget _buildMessageBubble(BuildContext context, bool isSender) {
    final BorderRadius radius = BorderRadius.only(
      topLeft: Radius.circular(isSender ? 12 : 0),
      topRight: Radius.circular(isSender ? 0 : 12),
      bottomLeft: Radius.circular(12),
      bottomRight: Radius.circular(12),
    );

    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.7,
      ),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isSender ? Colors.blue[100] : Colors.grey[200],
        borderRadius: radius,
      ),
      child: Text(
        message['content'],
        style: TextStyle(
          fontSize: 16,
          color: Colors.black87,
        ),
      ),
    );
  }
} 