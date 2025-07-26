import 'package:app_ui/src/scroll/notification_listener/scroll_listener_widget.dart';
import 'package:flutter/material.dart';

class MyPage extends StatefulWidget {
  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  bool _isScrolling = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('滚动监听示例'),
      ),
      body: Column(
        children: [
          // 显示滚动状态
          Container(
            padding: EdgeInsets.all(16),
            color: _isScrolling ? Colors.orange : Colors.green,
            child: Text(
              _isScrolling ? '正在滚动' : '滚动停止',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          // 使用封装的组件
          Expanded(
            child: ScrollListenerWidget(
              onScrollStateChanged: (isScrolling) {
                setState(() {
                  _isScrolling = isScrolling;
                });
              },
              onScrollStart: () {
                print('开始滚动');
              },
              onScrollEnd: () {
                print('滚动结束');
              },
              onScrollUpdate: () {
                print('滚动更新中...');
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
}
