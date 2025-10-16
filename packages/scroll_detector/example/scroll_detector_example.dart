import 'package:flutter/material.dart';
import 'package:scroll_detector/scroll_detector.dart';

class ScrollDetectorExample extends StatefulWidget {
  @override
  State<ScrollDetectorExample> createState() => _ScrollDetectorExampleState();
}

class _ScrollDetectorExampleState extends State<ScrollDetectorExample> {
  bool _isScrolling = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('滚动监听'),
      ),
      body: Column(
        children: [
          // 状态显示
          Container(
            padding: EdgeInsets.all(16),
            color: _isScrolling ? Colors.orange : Colors.green,
            child: Text(
              _isScrolling ? '正在滚动' : '滚动停止',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          // 滚动内容
          Expanded(
            child: ScrollDetector(
              scrollEndDelay: Duration(milliseconds: 300),
              onScrollStart: (offset, viewportDimension) {
                print('offset: $offset, viewportDimension: $viewportDimension');
              },
              onScrollEnd: (offset, viewportDimension) {
                print('offset: $offset, viewportDimension: $viewportDimension');
              },
              child: ListView.builder(
                controller: ScrollController(), // 这里会被组件内部的控制器替换
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
}
