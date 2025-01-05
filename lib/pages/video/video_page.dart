import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';

class VideoPageWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return VideoPage();
  }
}

class VideoPage extends StatefulWidget {
  @override
  _VideoPageState createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final Map<int, VideoPlayerController> _controllerCache = {};

  final List<Map<String, dynamic>> _videos = [
    {
      'videoUrl': 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
      'userAvatar': 'https://via.placeholder.com/150',
      'userName': '@用户1',
      'description': '这是第一个视频描述 #生活 #日常',
      'likes': '12.5w',
      'comments': '2.4w',
      'shares': '1.2w',
      'isFavorite': false,
    },
    {
      'videoUrl': 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
      'userAvatar': 'https://via.placeholder.com/150',
      'userName': '@用户2',
      'description': '快来和我一起玩吧 #户外 #亲子',
      'likes': '8.9w',
      'comments': '1.2w',
      'shares': '5642',
      'isFavorite': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeVideo(0);
    _preloadNextVideo(1);
  }

  Future<void> _preloadNextVideo(int index) async {
    if (index >= _videos.length || _controllerCache.containsKey(index)) return;

    try {
      final controller = VideoPlayerController.network(
        _videos[index]['videoUrl'],
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
        httpHeaders: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
        },
      );
      await controller.initialize();
      _controllerCache[index] = controller;
    } catch (e) {
      print('预加载视频失败: $e');
    }
  }

  Future<void> _initializeVideo(int index) async {
    if (_controllerCache.containsKey(index)) {
      _controllerCache[index]?.play();
      return;
    }

    try {
      final controller = VideoPlayerController.network(
        _videos[index]['videoUrl'],
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
        httpHeaders: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
        },
      );
      await controller.initialize();
      controller.play();
      controller.setLooping(true);
      _controllerCache[index] = controller;
      if (mounted) setState(() {});
    } catch (e) {
      print('初始化视频失败: $e');
    }
  }

  void _cleanupControllers(int currentIndex) {
    _controllerCache.forEach((index, controller) {
      if ((index - currentIndex).abs() > 1) {
        controller.dispose();
        _controllerCache.remove(index);
      } else if (index != currentIndex) {
        controller.pause();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            scrollDirection: Axis.vertical,
            controller: _pageController,
            itemCount: _videos.length,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
              _initializeVideo(index);
              _preloadNextVideo(index + 1);
              _cleanupControllers(index);
            },
            itemBuilder: (context, index) {
              return VideoItem(
                video: _videos[index],
                controller: _controllerCache[index],
                onFavoriteChanged: (bool isFavorite) {
                  setState(() {
                    _videos[index]['isFavorite'] = isFavorite;
                  });
                },
              );
            },
          ),
          // 顶部渐变阴影
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // 底部渐变阴影
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controllerCache.forEach((_, controller) => controller.dispose());
    _controllerCache.clear();
    _pageController.dispose();
    super.dispose();
  }
}

class VideoItem extends StatefulWidget {
  final Map<String, dynamic> video;
  final VideoPlayerController? controller;
  final Function(bool)? onFavoriteChanged;

  const VideoItem({
    Key? key,
    required this.video,
    this.controller,
    this.onFavoriteChanged,
  }) : super(key: key);

  @override
  _VideoItemState createState() => _VideoItemState();
}

class _VideoItemState extends State<VideoItem> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isPlaying = true;
  IconData _likeIcon = Icons.favorite_border;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat();

    _likeIcon = widget.video['isFavorite'] ? Icons.favorite : Icons.favorite_border;
  }

  Widget _buildLikeButton() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedSwitcher(
          transitionBuilder: (child, anim) {
            return ScaleTransition(child: child, scale: anim);
          },
          duration: Duration(milliseconds: 350),
          child: IconButton(
            key: ValueKey(_likeIcon),
            icon: Icon(
              _likeIcon,
              color: _likeIcon == Icons.favorite ? Colors.red : Colors.white,
              size: 32,
            ),
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(),
            onPressed: () {
              setState(() {
                _likeIcon = _likeIcon == Icons.favorite_border
                    ? Icons.favorite
                    : Icons.favorite_border;
                widget.onFavoriteChanged?.call(_likeIcon == Icons.favorite);
              });
            },
          ),
        ),
        SizedBox(height: 8),
        Text(
          widget.video['likes'],
          style: TextStyle(
            color: Colors.white,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    Color color = Colors.white,
    required VoidCallback onTap,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(icon, color: color, size: 32),
          padding: EdgeInsets.zero,
          constraints: BoxConstraints(),
          onPressed: onTap,
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildMusicDisc() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: widget.video['userAvatar'],
          fit: BoxFit.cover,
          placeholder: (context, url) => CircularProgressIndicator(),
          errorWidget: (context, url, error) => Icon(Icons.error),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (widget.controller?.value.isInitialized ?? false)
            GestureDetector(
              onTap: () {
                setState(() {
                  _isPlaying = !_isPlaying;
                  _isPlaying ? widget.controller?.play() : widget.controller?.pause();
                });
              },
              child: AspectRatio(
                aspectRatio: widget.controller!.value.aspectRatio,
                child: VideoPlayer(widget.controller!),
              ),
            )
          else
            Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            ),

          if (!_isPlaying && (widget.controller?.value.isInitialized ?? false))
            GestureDetector(
              onTap: () {
                setState(() {
                  _isPlaying = true;
                  widget.controller?.play();
                });
              },
              child: Container(
                color: Colors.black.withOpacity(0.3),
                child: Center(
                  child: Icon(
                    Icons.play_arrow,
                    size: 80,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ),
            ),

          Positioned(
            right: 16,
            bottom: 30,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildLikeButton(),
                SizedBox(height: 20),
                _buildActionButton(
                  icon: Icons.comment,
                  label: widget.video['comments'],
                  onTap: () {},
                ),
                SizedBox(height: 20),
                _buildActionButton(
                  icon: Icons.share,
                  label: widget.video['shares'],
                  onTap: () {},
                ),
                SizedBox(height: 20),
                RotationTransition(
                  turns: _animationController,
                  child: _buildMusicDisc(),
                ),
              ],
            ),
          ),

          Positioned(
            left: 16,
            right: 88,
            bottom: 30,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.video['userName'],
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  widget.video['description'],
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
} 