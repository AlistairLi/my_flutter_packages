import 'package:flutter/material.dart';
import 'package:scroll_detector/src/advanced_scroll_detector.dart';
import 'package:scroll_detector/src/directional_scroll_detector.dart';

class AdvancedScrollExample extends StatefulWidget {
  @override
  State<AdvancedScrollExample> createState() => _AdvancedScrollExampleState();
}

class _AdvancedScrollExampleState extends State<AdvancedScrollExample> {
  bool _isScrolling = false;
  ScrollDirection _direction = ScrollDirection.none;
  double _progress = 0.0;
  bool _showBackToTop = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('高级滚动监听'),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // 状态显示
              Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16),
                            decoration: BoxDecoration(
                              color:
                                  _isScrolling ? Colors.orange : Colors.green,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _isScrolling ? '滚动中' : '停止',
                              style: TextStyle(color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16),
                            decoration: BoxDecoration(
                              color: _getDirectionColor(),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _getDirectionText(),
                              style: TextStyle(color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: _progress,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  ],
                ),
              ),
              // 滚动内容
              Expanded(
                child: AdvancedScrollDetector(
                  onScrollStateChanged: (isScrolling) {
                    setState(() {
                      _isScrolling = isScrolling;
                    });
                  },
                  onScrollDirectionChanged: (direction) {
                    setState(() {
                      _direction = direction;
                    });
                  },
                  onScrollProgress: (offset, maxExtent) {
                    setState(() {
                      _progress = maxExtent > 0 ? offset / maxExtent : 0.0;
                      _showBackToTop = offset > 1000; // 滚动超过1000px显示回到顶部按钮
                    });
                  },
                  onReachTop: () {
                    print('到达顶部');
                  },
                  onReachBottom: () {
                    print('到达底部');
                  },
                  child: ListView.builder(
                    itemCount: 100,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text('项目 $index'),
                        subtitle: Text('这是第 $index 个项目'),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          // 回到顶部按钮
          Positioned(
            right: 16,
            bottom: 16,
            child: AnimatedOpacity(
              opacity: _showBackToTop ? 1.0 : 0.0,
              duration: Duration(milliseconds: 300),
              child: FloatingActionButton(
                mini: true,
                onPressed: () {
                  // 这里需要访问控制器来滚动到顶部
                },
                child: Icon(Icons.keyboard_arrow_up),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getDirectionColor() {
    switch (_direction) {
      case ScrollDirection.up:
        return Colors.blue;
      case ScrollDirection.down:
        return Colors.red;
      case ScrollDirection.none:
        return Colors.grey;
    }
  }

  String _getDirectionText() {
    switch (_direction) {
      case ScrollDirection.up:
        return '向上';
      case ScrollDirection.down:
        return '向下';
      case ScrollDirection.none:
        return '无';
    }
  }
}
