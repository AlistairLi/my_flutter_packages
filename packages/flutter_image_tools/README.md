# flutter_image_tools

flutter_image_tools 是一个专为 Flutter 打造的本地图像处理工具库，专注于提供跨平台（Android / iOS）高性能、易用的图片处理能力。

它整合了 Dart 层图像处理与部分原生平台特性，帮助你在移动端实现常见的图像处理任务，包括：

- 图片格式转换
- 图像方向修正
- 添加水印
- 裁剪 / 缩放 / 旋转
- 圆角处理 / 添加边框
- 应用滤镜
- 批量处理
- 获取图像元信息
- 智能图片压缩

该库适用于：
- 社交、聊天类应用（头像处理、水印加签）
- 内容创作类工具（裁剪、滤镜）
- 图片上传时压缩优化等场景

## 功能特性

### 🎯 智能压缩
- 自动检测图片大小
- 智能质量与尺寸压缩策略
- 支持多种格式（JPEG、PNG、WebP）
- 可配置目标大小和质量

### 🔄 格式转换
- 支持 JPEG、PNG、WebP 格式互转
- 保持图片质量
- 批量转换支持

### 📐 图像处理
- 缩放：支持多种适配模式（contain、cover、fill）
- 旋转：任意角度旋转
- 裁剪：精确区域裁剪
- 圆角：支持圆角和圆形裁剪
- 边框：可自定义边框样式

### 🎨 特效处理
- 水印：支持图片水印添加
- 滤镜：亮度、对比度、饱和度、色相调整
- 边框：支持多种边框样式

### 📊 批量处理
- 批量压缩
- 批量格式转换
- 批量图像处理
- 错误处理和进度跟踪

### 📏 文件大小常量
- 预定义常用文件大小常量
- 简化配置，提高代码可读性
- 支持头像、缩略图、大图等不同场景

## 快速开始

### 安装依赖

```yaml
dependencies:
  flutter_image_tools: ^1.0.0
```

### 基本使用

```dart
import 'package:flutter_image_tools/flutter_image_tools.dart';

// 使用预定义大小常量进行智能压缩
final compressor = SmartCompressor();

// 头像压缩（200KB）
final avatarOptions = CompressionOptions(
  targetSize: FileSize.avatarSize,
  quality: 80,
  format: 'jpeg',
);

// 缩略图压缩（50KB）
final thumbnailOptions = CompressionOptions(
  targetSize: FileSize.thumbnailSize,
  quality: 70,
  format: 'jpeg',
);

// 大图片压缩（1MB）
final largeImageOptions = CompressionOptions(
  targetSize: FileSize.largeImage,
  quality: 85,
  format: 'jpeg',
);

final result = await compressor.process('/path/to/image.jpg', avatarOptions);
if (result != null) {
  print('压缩成功：${result.fileSize} bytes');
}

// 批量处理
final batchProcessor = BatchProcessor();
final imagePaths = ['/path/to/image1.jpg', '/path/to/image2.jpg'];
final results = await batchProcessor.compressBatch(imagePaths, avatarOptions);
print('批量处理完成：${results.length} 张图片');

// 检查是否需要压缩
final shouldCompress = await SmartCompressor.shouldCompress('/path/to/image.jpg');
print('是否需要压缩：$shouldCompress');
```

### 高级使用

```dart
// 缩放图片
final resizer = Resizer();
final resizeOptions = ResizeOptions(
  targetWidth: 800,
  targetHeight: 600,
  maintainAspectRatio: true,
  fitMode: 'contain',
);

final resizedResult = await resizer.process('/path/to/image.jpg', resizeOptions);

// 添加水印
final watermarkAdder = WatermarkAdder();
final watermarkConfig = WatermarkConfig(
  watermarkPath: '/path/to/watermark.png',
  x: 10,
  y: 10,
  opacity: 0.8,
  scale: 1.0,
);

final watermarkedResult = await watermarkAdder.process('/path/to/image.jpg', watermarkConfig);
```

## 贡献

欢迎提交 Issue 和 Pull Request！

## 许可证

MIT License