import 'package:flutter/material.dart';
import 'package:scroll_detector/src/directional_scroll_detector.dart';

class DirectionalScrollExample extends StatefulWidget {
  @override
  _DirectionalScrollExampleState createState() =>
      _DirectionalScrollExampleState();
}

class _DirectionalScrollExampleState extends State<DirectionalScrollExample> {
  bool _isScrolling = false;
  ScrollDirection _direction = ScrollDirection.none;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('方向滚动监听'),
      ),
      body: Column(
        children: [
          // 状态显示
          Container(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  decoration: BoxDecoration(
                    color: _isScrolling ? Colors.orange : Colors.green,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _isScrolling ? '正在滚动' : '滚动停止',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  decoration: BoxDecoration(
                    color: _getDirectionColor(),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '方向: ${_getDirectionText()}',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          // 滚动内容
          Expanded(
            child: DirectionalScrollDetector(
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
