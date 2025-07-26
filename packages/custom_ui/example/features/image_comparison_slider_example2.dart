import 'package:custom_ui/src/features/image_comparison_slider.dart';
import 'package:flutter/material.dart';

/// 图片对比滑块使用示例
class ImageComparisonSliderExample2 extends StatelessWidget {
  const ImageComparisonSliderExample2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('图片对比滑块示例'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('基础用法'),
            _buildBasicExample(context),
            const SizedBox(height: 32),
            _buildSectionTitle('自定义适配比例'),
            _buildCustomScaleExample(context),
            const SizedBox(height: 32),
            _buildSectionTitle('不同屏幕尺寸适配'),
            _buildAdaptiveExample(context),
            const SizedBox(height: 32),
            _buildSectionTitle('自定义样式'),
            _buildCustomStyleExample(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// 基础用法示例
  Widget _buildBasicExample(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('使用默认适配比例 (scaleFactor: 1.0)'),
            const SizedBox(height: 8),
            ImageComparisonSlider(
              beforeWidget: _buildPlaceholderImage('处理前', Colors.blue),
              afterWidget: _buildPlaceholderImage('处理后', Colors.green),
              height: 200,
              onPositionChanged: (position) {
                print('滑块位置: ${(position * 100).toStringAsFixed(1)}%');
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 自定义适配比例示例
  Widget _buildCustomScaleExample(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('使用自定义适配比例 (scaleFactor: 1.2)'),
            const SizedBox(height: 8),
            ImageComparisonSlider(
              beforeWidget: _buildPlaceholderImage('处理前', Colors.red),
              afterWidget: _buildPlaceholderImage('处理后', Colors.orange),
              height: 200,
              scaleFactor: 1.2,
              onPositionChanged: (position) {
                print('滑块位置: ${(position * 100).toStringAsFixed(1)}%');
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 自适应适配示例
  Widget _buildAdaptiveExample(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('使用自适应适配比例 (scaleFactor: })'),
            const SizedBox(height: 8),
            ImageComparisonSlider(
              beforeWidget: _buildPlaceholderImage('处理前', Colors.purple),
              afterWidget: _buildPlaceholderImage('处理后', Colors.pink),
              height: 200,
              onPositionChanged: (position) {
                print('滑块位置: ${(position * 100).toStringAsFixed(1)}%');
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 自定义样式示例
  Widget _buildCustomStyleExample(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('自定义样式配置'),
            const SizedBox(height: 8),
            ImageComparisonSlider(
              beforeWidget: _buildPlaceholderImage('Before', Colors.indigo),
              afterWidget: _buildPlaceholderImage('After', Colors.teal),
              height: 200,
              borderRadius: 20,
              sliderHandleWidth: 60,
              showLabels: true,
              beforeLabel: 'Before',
              afterLabel: 'After',
              labelBackgroundBlur: true,
              onPositionChanged: (position) {
                print('滑块位置: ${(position * 100).toStringAsFixed(1)}%');
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 构建占位图片
  Widget _buildPlaceholderImage(String text, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.3),
        border: Border.all(color: color, width: 2),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image,
              size: 48,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              text,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 使用示例页面
class ImageComparisonSliderPage extends StatelessWidget {
  const ImageComparisonSliderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ImageComparisonSliderExample2();
  }
}
