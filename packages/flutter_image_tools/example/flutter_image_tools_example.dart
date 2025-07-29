import 'package:flutter_image_tools/flutter_image_tools.dart';

void main() async {
  // 示例：使用智能压缩器
  final compressor = SmartCompressor();

  // 使用预定义的大小常量
  final avatarOptions = CompressionOptions(
    targetSize: FileSize.avatarSize, // 200KB
    quality: 80,
    format: 'jpeg',
  );

  final thumbnailOptions = CompressionOptions(
    targetSize: FileSize.thumbnailSize, // 50KB
    quality: 70,
    format: 'jpeg',
  );

  final largeImageOptions = CompressionOptions(
    targetSize: FileSize.largeImage, // 1MB
    quality: 85,
    format: 'jpeg',
  );

  // 压缩头像
  final avatarResult =
      await compressor.process('/path/to/avatar.jpg', avatarOptions);
  if (avatarResult != null) {
    print('头像压缩成功：${avatarResult.fileSize} bytes');
  }

  // 压缩缩略图
  final thumbnailResult =
      await compressor.process('/path/to/image.jpg', thumbnailOptions);
  if (thumbnailResult != null) {
    print('缩略图压缩成功：${thumbnailResult.fileSize} bytes');
  }

  // 压缩大图片
  final largeImageResult =
      await compressor.process('/path/to/large_image.jpg', largeImageOptions);
  if (largeImageResult != null) {
    print('大图片压缩成功：${largeImageResult.fileSize} bytes');
  }

  // 示例：使用批量处理器
  final batchProcessor = BatchProcessor();
  final imagePaths = ['/path/to/image1.jpg', '/path/to/image2.jpg'];
  final results = await batchProcessor.compressBatch(imagePaths, avatarOptions);
  print('批量处理完成：${results.length} 张图片');

  // 示例：检查是否需要压缩
  final shouldCompress =
      await SmartCompressor().shouldCompress('/path/to/image.jpg');
  print('是否需要压缩：$shouldCompress');

  // 示例：使用自定义阈值
  final customThreshold = await SmartCompressor().shouldCompress(
    '/path/to/image.jpg',
    threshold: FileSize.mediumImage, // 500KB
  );
  print('使用自定义阈值检查：$customThreshold');
}
