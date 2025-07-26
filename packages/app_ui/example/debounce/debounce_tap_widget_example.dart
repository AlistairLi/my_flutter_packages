import 'package:app_ui/src/debounce/debounced_tap_widget.dart';
import 'package:flutter/material.dart';

/// 防抖动 Widget 使用示例
class DebounceTapWidgetExample extends StatefulWidget {
  const DebounceTapWidgetExample({super.key});

  @override
  State<DebounceTapWidgetExample> createState() => _DebounceTapWidgetExampleState();
}

class _DebounceTapWidgetExampleState extends State<DebounceTapWidgetExample> {
  int _clickCount = 0;
  int _debounceClickCount = 0;

  void _handleNormalClick() {
    setState(() {
      _clickCount++;
    });
    print('普通点击: $_clickCount');
  }

  void _handleDebounceClick() {
    setState(() {
      _debounceClickCount++;
    });
    print('防抖动点击: $_debounceClickCount');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('防抖动 Widget 示例'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 普通按钮示例
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      '普通按钮（无防抖动）',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text('点击次数: $_clickCount'),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _handleNormalClick,
                      child: const Text('快速点击我'),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 防抖动按钮示例
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      '防抖动按钮（500ms 防抖）',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text('点击次数: $_debounceClickCount'),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 自定义防抖动时间示例
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      '自定义防抖动时间（1000ms）',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 自定义防抖动 Widget 示例
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      '自定义防抖动 Widget',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    DebouncedTapWidget(
                      onTap: () => print('自定义防抖动 Widget 被点击'),
                      debounceDuration: 800,
                      enableFeedback: true,
                      feedbackColor: Colors.blue.withOpacity(0.3),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          '自定义样式按钮',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 图片防抖动示例
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      '图片防抖动示例',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    DebouncedTapWidget(
                      onTap: () => print('图片被点击'),
                      debounceDuration: 300,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.image,
                          size: 50,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 