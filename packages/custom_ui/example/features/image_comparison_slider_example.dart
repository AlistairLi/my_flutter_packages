import 'package:custom_ui/src/features/image_comparison_slider.dart';
import 'package:flutter/material.dart';

/// 前后对比图 示例
class ImageComparisonSliderExample extends StatefulWidget {
  const ImageComparisonSliderExample({super.key});

  @override
  State<ImageComparisonSliderExample> createState() =>
      _ImageComparisonSliderExampleState();
}

class _ImageComparisonSliderExampleState
    extends State<ImageComparisonSliderExample> {
  double _currentPosition = 0.5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('图片裁剪示例'),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF90EE90).withOpacity(0.3),
              const Color(0xFFFFB6C1).withOpacity(0.3),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                // 图片裁剪组件
                ImageComparisonSlider(
                  beforeWidget: Image.asset(
                    "assets/images/xx.png", // TODO 替换图片路径
                    fit: BoxFit.cover,
                  ),
                  afterWidget: Image.asset(
                    "assets/images/xx.png", // TODO 替换图片路径
                    fit: BoxFit.cover,
                  ),
                  handleIcon: "assets/images/xx.png",
                  // TODO 替换图片路径
                  height: 400,
                  borderRadius: 16,
                  initialPosition: _currentPosition,
                  labelBackgroundBlur: true,
                  test: true,
                  onPositionChanged: (position) {
                    setState(() {
                      _currentPosition = position;
                    });
                    print('裁剪位置: ${(position * 100).toStringAsFixed(1)}%');
                  },
                ),

                SizedBox(height: 20),

                // 位置指示器
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        '当前裁剪位置',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '${(_currentPosition * 100).toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFFF6B9D),
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        '拖拽中间的控制条来调整裁剪区域',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20),

                // 重置按钮
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentPosition = 0.5;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6B9D),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '重置到中间位置',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
