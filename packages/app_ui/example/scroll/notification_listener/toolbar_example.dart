import 'package:app_ui/src/scroll/notification_listener/advanced_scroll_listener_widget.dart';
import 'package:flutter/material.dart';

/// 延迟滚动监听示例-隐藏/显示工具栏
class ToolbarExample extends StatefulWidget {
  @override
  State<ToolbarExample> createState() => _ToolbarExampleState();
}

class _ToolbarExampleState extends State<ToolbarExample> {
  bool _showToolbar = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 工具栏 - 滚动时隐藏，停止时显示
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            height: _showToolbar ? 60 : 0,
            child: Container(
              color: Colors.blue,
              child: Row(
                children: [
                  IconButton(icon: Icon(Icons.home), onPressed: () {}),
                  IconButton(icon: Icon(Icons.search), onPressed: () {}),
                  IconButton(icon: Icon(Icons.settings), onPressed: () {}),
                ],
              ),
            ),
          ),
          // 内容区域
          Expanded(
            child: AdvancedScrollListenerWidget(
              scrollEndDelay: Duration(milliseconds: 500), // 500ms延迟
              onScrollStateChanged: (isScrolling) {
                setState(() {
                  _showToolbar = !isScrolling; // 滚动时隐藏，停止时显示
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
}
