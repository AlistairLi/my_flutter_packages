import 'package:app_ui/src/scroll/notification_listener/advanced_scroll_listener_widget.dart';
import 'package:flutter/material.dart';

/// 延迟滚动监听示例-图片浏览器的缩放控制
class ImageViewerExample extends StatefulWidget {
  @override
  State<ImageViewerExample> createState() => _ImageViewerExampleState();
}

class _ImageViewerExampleState extends State<ImageViewerExample> {
  bool _showControls = true;
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 图片内容
          AdvancedScrollListenerWidget(
            scrollEndDelay: Duration(milliseconds: 2000), // 2秒延迟
            onScrollStateChanged: (isScrolling) {
              setState(() {
                _showControls = !isScrolling;
              });
            },
            child: InteractiveViewer(
              scaleEnabled: true,
              child: Image.network(
                'https://example.com/large-image.jpg',
                fit: BoxFit.contain,
              ),
            ),
          ),
          // 控制按钮 - 滚动时隐藏
          AnimatedOpacity(
            opacity: _showControls ? 1.0 : 0.0,
            duration: Duration(milliseconds: 300),
            child: Container(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  IconButton(
                    icon: Icon(Icons.share, color: Colors.white),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
