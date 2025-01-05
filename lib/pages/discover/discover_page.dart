import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class DiscoverPage extends StatefulWidget {
  @override
  _DiscoverPageState createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 10),
              child: CircleAvatar(
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: "https://q.qlogo.cn/headimg_dl?dst_uin=3255419561&spec=640",
                    placeholder: (context, url) => CircularProgressIndicator(),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                    fit: BoxFit.cover,
                  ),
                ),
                radius: 16,
              ),
            ),
            SizedBox(width: 4),
            Text('发现',
                style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.settings, color: Colors.black),
            onPressed: () {},
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
      ),
      backgroundColor: const Color(0xF5F5F5),
      body: Padding(
        padding: EdgeInsets.only(left: 10),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 160,
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Stack(
                  children: [
                    Image.network(
                      'https://via.placeholder.com/600x400?text=Banner+Image',
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      bottom: 16,
                      left: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '今日天气',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '多云，20°C',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDiscoverItem(
                      Icons.location_on_outlined,
                      '附近',
                      Icons.arrow_forward_ios,
                      subTitle: '周围有23个人在EMO',
                    ),
                    _buildDiscoverItem(
                      Icons.cloud_outlined,
                      '化身',
                      Icons.arrow_forward_ios,
                      subTitle: '与另一个你不期而遇',
                    ),
                    _buildDiscoverItem(
                        Icons.remove_red_eye,
                        '活动',
                        Icons.arrow_forward_ios
                    ),
                    _buildDiscoverItem(
                        Icons.book,
                        '阅读',
                        Icons.arrow_forward_ios
                    ),
                    _buildDiscoverItem(
                        Icons.more_horiz,
                        '更多',
                        Icons.arrow_forward_ios
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDiscoverItem(IconData icon, String title, IconData trailingIcon,
      {String? subTitle}) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Spacer(),
                    if (subTitle != null && subTitle.isNotEmpty)
                      Text(
                        subTitle,
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                  ],
                ),
              ],
            ),
          ),
          Icon(trailingIcon),
        ],
      ),
    );
  }
} 