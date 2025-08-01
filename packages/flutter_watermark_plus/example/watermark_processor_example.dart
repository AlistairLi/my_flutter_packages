import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_watermark_plus/flutter_watermark_plus.dart';
// import 'package:image_picker/image_picker.dart';

/// WatermarkProcessor 使用示例
/// 
/// 展示如何使用 WatermarkProcessor 为图片添加水印
class WatermarkProcessorExample extends StatefulWidget {
  const WatermarkProcessorExample({super.key});

  @override
  State<WatermarkProcessorExample> createState() => _WatermarkProcessorExampleState();
}

class _WatermarkProcessorExampleState extends State<WatermarkProcessorExample> {
  final WatermarkProcessor _processor = WatermarkProcessor();
  // final ImagePicker _picker = ImagePicker();
  
  String? _originalImagePath;
  String? _watermarkedImagePath;
  bool _isProcessing = false;
  String _watermarkText = 'CONFIDENTIAL';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WatermarkProcessor 示例'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildControls(),
            const SizedBox(height: 20),
            _buildImageDisplay(),
            const SizedBox(height: 20),
            _buildExamples(),
          ],
        ),
      ),
    );
  }

  /// 构建控制面板
  Widget _buildControls() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '控制面板',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // 水印文本输入
            TextField(
              decoration: const InputDecoration(
                labelText: '水印文本',
                border: OutlineInputBorder(),
              ),
              // value: _watermarkText,
              onChanged: (value) => setState(() => _watermarkText = value),
            ),
            const SizedBox(height: 16),
            
            // 操作按钮
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isProcessing ? null : _pickImage,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('选择图片'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: (_isProcessing || _originalImagePath == null) 
                        ? null 
                        : _addWatermark,
                    icon: const Icon(Icons.water_drop),
                    label: const Text('添加水印'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 构建图片显示区域
  Widget _buildImageDisplay() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '图片预览',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            if (_isProcessing)
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 8),
                    Text('正在处理图片...'),
                  ],
                ),
              )
            else if (_originalImagePath != null)
              Column(
                children: [
                  // 原图
                  if (_originalImagePath != null) ...[
                    const Text('原图:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Image.file(
                      File(_originalImagePath!),
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // 水印图
                  if (_watermarkedImagePath != null) ...[
                    const Text('水印图:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Image.file(
                      File(_watermarkedImagePath!),
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ],
                ],
              )
            else
              const Center(
                child: Column(
                  children: [
                    Icon(Icons.image, size: 64, color: Colors.grey),
                    SizedBox(height: 8),
                    Text('请选择一张图片'),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 构建示例代码
  Widget _buildExamples() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '使用示例',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            const Text(
              '1. 创建 WatermarkProcessor 实例:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(top: 4, bottom: 12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'final processor = WatermarkProcessor();',
                style: TextStyle(fontFamily: 'monospace'),
              ),
            ),
            
            const Text(
              '2. 为图片字节添加水印:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(top: 4, bottom: 12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                '''final watermarkedBytes = await processor.addWatermark(
  imageBytes: originalBytes,
  text: 'CONFIDENTIAL',
  config: Config(
    textStyle: TextStyle(color: Colors.red),
    rotationAngle: -0.785,
  ),
);''',
                style: TextStyle(fontFamily: 'monospace'),
              ),
            ),
            
            const Text(
              '3. 为文件路径添加水印:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                '''final outputPath = await processor.addWatermarkToFilePath(
  inputPath: '/path/to/image.jpg',
  text: 'CONFIDENTIAL',
  config: Config(),
  overwrite: false,
);''',
                style: TextStyle(fontFamily: 'monospace'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 选择图片
  Future<void> _pickImage() async {
    // try {
    //   final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    //   if (image != null) {
    //     setState(() {
    //       _originalImagePath = image.path;
    //       _watermarkedImagePath = null;
    //     });
    //   }
    // } catch (e) {
    //   _showError('选择图片失败: $e');
    // }
  }

  /// 添加水印
  Future<void> _addWatermark() async {
    if (_originalImagePath == null) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // 示例1: 使用文件路径
      final outputPath = await _processor.addWatermarkToFilePath(
        inputPath: _originalImagePath!,
        text: _watermarkText,
        config: Config(
          textStyle: const TextStyle(
            color: Colors.red,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          rotationAngle: -0.785, // -45度
          horizontalInterval: 150,
          verticalInterval: 150,
        ),
        overwrite: false,
      );

      setState(() {
        _watermarkedImagePath = outputPath;
        _isProcessing = false;
      });

      _showSuccess('水印添加成功!');
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      _showError('添加水印失败: $e');
    }
  }

  /// 显示成功消息
  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  /// 显示错误消息
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
