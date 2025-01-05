import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: ChatPage(username: '甜甜的酪梨酱'),
  ));
}

class ChatPage extends StatefulWidget {
  final String username;

  ChatPage({required this.username});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<Map<String, dynamic>> messages = [
    {"text": "你听说莹宝和找哥的事了吗?", "sender": "other", "avatar": "https://via.placeholder.com/50"},
    {"text": "他们居然真的在一起了! 昨天官宣了,真的是太美好了 💖", "sender": "other", "avatar": "https://via.placeholder.com/50"},
    {"text": "好羡慕他们啊 😭", "sender": "me", "avatar": "https://via.placeholder.com/50"},
    {"text": "哈哈哈, 我看到了", "sender": "other", "avatar": "https://via.placeholder.com/50"},
  ];

  final TextEditingController _controller = TextEditingController();

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        messages.add({
          "text": _controller.text,
          "sender": "me",
          "avatar": "https://via.placeholder.com/50",
        });
        _controller.clear();
      });
    }
  }

  Widget _buildMessage(String text, String sender, String avatarUrl) {
    bool isMe = sender == "me";
    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: <Widget>[
        if (!isMe)
          CircleAvatar(
            backgroundImage: NetworkImage(avatarUrl),
            radius: 15,
          ),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.6),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isMe ? const Color(0xFF98E165) : const Color(0xFF57A0F6),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: Radius.circular(isMe ? 20 : 0),
                bottomRight: Radius.circular(isMe ? 0 : 20),
              ),
            ),
            child: Text(
              text,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        if (isMe)
          CircleAvatar(
            backgroundImage: NetworkImage(avatarUrl),
            radius: 15,
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.username),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        actions: [
          IconButton(icon: Icon(Icons.phone), onPressed: () {}),
          IconButton(icon: Icon(Icons.more_vert), onPressed: () {}),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Container(color: Colors.grey[300], height: 1),
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final reversedIndex = messages.length - 1 - index;
                var message = messages[reversedIndex];
                return _buildMessage(message["text"], message["sender"], message['avatar']);
              },
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey[300]!, width: 1)),
            ),
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onChanged: (text) {
                      setState(() {});
                    },
                    decoration: InputDecoration(
                      hintText: "打招呼...",
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                IconButton(icon: Icon(Icons.mic), onPressed: () {}),
                if (_controller.text.isNotEmpty)
                  IconButton(
                    icon: Icon(Icons.send),
                    onPressed: _sendMessage,
                  ),
                if (_controller.text.isEmpty)
                  IconButton(
                    icon: Icon(Icons.add_circle_outline),
                    onPressed: () {},
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
