import 'package:app_ui/src/scroll/notification_listener/advanced_scroll_listener_widget.dart';
import 'package:flutter/material.dart';

/// 延迟滚动监听示例-阅读器的进度指示器
class ReaderExample extends StatefulWidget {
  @override
  State<ReaderExample> createState() => _ReaderExampleState();
}

class _ReaderExampleState extends State<ReaderExample> {
  bool _showProgress = false;
  double _progress = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 阅读内容
          AdvancedScrollListenerWidget(
            scrollEndDelay: Duration(milliseconds: 1000), // 1秒延迟
            onScrollStateChanged: (isScrolling) {
              setState(() {
                _showProgress = isScrolling;
              });
            },
            onScrollUpdate: () {
              // 计算阅读进度
              // 这里需要根据实际滚动位置计算
            },
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  '这里是阅读内容...',
                  style: TextStyle(fontSize: 18, height: 1.6),
                ),
              ),
            ),
          ),
          // 进度指示器
          Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: AnimatedOpacity(
              opacity: _showProgress ? 1.0 : 0.0,
              duration: Duration(milliseconds: 300),
              child: Container(
                height: 4,
                child: LinearProgressIndicator(
                  value: _progress,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
