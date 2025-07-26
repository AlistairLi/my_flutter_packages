import 'package:app_ui/src/scroll/controller_listener/scroll_controller_listener_widget.dart';
import 'package:flutter/material.dart';

class BasicScrollExample extends StatefulWidget {
  @override
  State<BasicScrollExample> createState() => _BasicScrollExampleState();
}

class _BasicScrollExampleState extends State<BasicScrollExample> {
  bool _isScrolling = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('基础滚动监听'),
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
            child: ScrollControllerListenerWidget(
              scrollEndDelay: Duration(milliseconds: 300),
              onScrollStateChanged: (isScrolling) {
                setState(() {
                  _isScrolling = isScrolling;
                });
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
