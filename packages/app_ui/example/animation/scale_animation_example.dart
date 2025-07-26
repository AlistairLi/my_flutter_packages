import 'package:app_ui/src/animation/scale_animation_widget.dart';
import 'package:flutter/material.dart';

/// 缩放动画 Widget 使用示例
class ScaleAnimationExample extends StatefulWidget {
  const ScaleAnimationExample({super.key});

  @override
  State<ScaleAnimationExample> createState() => _ScaleAnimationExampleState();
}

class _ScaleAnimationExampleState extends State<ScaleAnimationExample> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('缩放动画示例'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 基础缩放动画示例
            _buildSection(
              title: '基础缩放动画',
              description: '从小变大到1.2倍再恢复原大小',
              child: ScaleAnimationWidget(
                child: _buildDemoBox('基础缩放', Colors.blue),
                autoPlay: true,
                onAnimationComplete: () {
                  print('基础缩放动画完成');
                },
              ),
            ),

            const SizedBox(height: 20),

            // 脉冲动画示例
            _buildSection(
              title: '脉冲动画',
              description: '循环播放的脉冲效果',
              child: PulseScaleWidget(
                child: _buildDemoBox('脉冲效果', Colors.green),
                onAnimationComplete: () {
                  print('脉冲动画完成');
                },
              ),
            ),

            const SizedBox(height: 20),

            // 点击触发动画示例
            _buildSection(
              title: '点击触发动画',
              description: '点击时触发缩放动画',
              child: TapScaleWidget(
                child: _buildDemoBox('点击触发', Colors.orange),
                onTap: () {
                  print('点击触发了缩放动画');
                },
              ),
            ),

            const SizedBox(height: 20),

            // 自定义参数示例
            _buildSection(
              title: '自定义参数',
              description: '自定义缩放倍数、时长等参数',
              child: ScaleAnimationWidget(
                child: _buildDemoBox('自定义参数', Colors.purple),
                duration: const Duration(milliseconds: 800),
                maxScale: 1.5,
                minScale: 0.6,
                curve: Curves.elasticOut,
                autoPlay: true,
                loop: true,
                loopInterval: const Duration(seconds: 3),
                onAnimationComplete: () {
                  print('自定义参数动画完成');
                },
              ),
            ),

            const SizedBox(height: 20),

            // 图标动画示例
            _buildSection(
              title: '图标动画',
              description: '对图标应用缩放动画',
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  PulseScaleWidget(
                    child: Icon(
                      Icons.favorite,
                      size: 50,
                      color: Colors.red,
                    ),
                  ),
                  TapScaleWidget(
                    child: Icon(
                      Icons.star,
                      size: 50,
                      color: Colors.yellow,
                    ),
                    onTap: () {
                      print('星星图标被点击');
                    },
                  ),
                  ScaleAnimationWidget(
                    child: Icon(
                      Icons.thumb_up,
                      size: 50,
                      color: Colors.blue,
                    ),
                    autoPlay: true,
                    loop: true,
                    loopInterval: const Duration(seconds: 2),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 按钮动画示例
            _buildSection(
              title: '按钮动画',
              description: '对按钮应用缩放动画',
              child: Column(
                children: [
                  TapScaleWidget(
                    child: ElevatedButton(
                      onPressed: () {
                        print('按钮被点击');
                      },
                      child: const Text('点击我'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  PulseScaleWidget(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '脉冲按钮',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 图片动画示例
            _buildSection(
              title: '图片动画',
              description: '对图片应用缩放动画',
              child: Center(
                child: ScaleAnimationWidget(
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
                  autoPlay: true,
                  loop: true,
                  loopInterval: const Duration(seconds: 4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String description,
    required Widget child,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            Center(child: child),
          ],
        ),
      ),
    );
  }

  Widget _buildDemoBox(String text, Color color) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
