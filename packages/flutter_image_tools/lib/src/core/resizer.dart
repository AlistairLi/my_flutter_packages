import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';

import '../flutter_image_tools_base.dart';

/// 图像缩放器
class Resizer implements ImageProcessor {
  const Resizer();

  @override
  Future<ImageProcessingResult?> process(
    String imagePath,
    ProcessingOptions options,
  ) async {
    if (options is! ResizeOptions) {
      throw ArgumentError('Options must be ResizeOptions');
    }

    try {
      final file = File(imagePath);
      if (!await file.exists()) {
        return null;
      }

      // 获取原始图像信息
      final originalInfo = await getImageInfo(imagePath);
      if (originalInfo == null) {
        return null;
      }

      // 计算缩放比例
      final scale = _calculateScale(
        originalInfo.width,
        originalInfo.height,
        options.targetWidth,
        options.targetHeight,
        options.fitMode,
        options.maintainAspectRatio,
      );

      // 执行缩放
      final resizedData = await FlutterImageCompress.compressWithFile(
        imagePath,
        format: CompressFormat.jpeg,
        quality: 100, // 保持最高质量
        inSampleSize: scale,
      );

      if (resizedData != null) {
        final newWidth = originalInfo.width ~/ scale;
        final newHeight = originalInfo.height ~/ scale;

        return ImageProcessingResult(
          data: resizedData,
          format: 'jpeg',
          width: newWidth,
          height: newHeight,
          fileSize: resizedData.length,
        );
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// 计算缩放比例
  int _calculateScale(
    int originalWidth,
    int originalHeight,
    int targetWidth,
    int targetHeight,
    String fitMode,
    bool maintainAspectRatio,
  ) {
    if (!maintainAspectRatio) {
      // 如果不保持宽高比，使用较大的缩放比例
      final scaleX = originalWidth / targetWidth;
      final scaleY = originalHeight / targetHeight;
      return (scaleX > scaleY ? scaleX : scaleY).ceil();
    }

    switch (fitMode) {
      case 'contain':
        // 包含模式：确保整个图像都显示
        final scaleX = originalWidth / targetWidth;
        final scaleY = originalHeight / targetHeight;
        return (scaleX > scaleY ? scaleX : scaleY).ceil();
      
      case 'cover':
        // 覆盖模式：填满目标区域，可能裁剪
        final scaleX = originalWidth / targetWidth;
        final scaleY = originalHeight / targetHeight;
        return (scaleX < scaleY ? scaleX : scaleY).ceil();
      
      case 'fill':
        // 填充模式：拉伸到目标尺寸
        final scaleX = originalWidth / targetWidth;
        final scaleY = originalHeight / targetHeight;
        return (scaleX > scaleY ? scaleX : scaleY).ceil();
      
      default:
        // 默认使用包含模式
        final scaleX = originalWidth / targetWidth;
        final scaleY = originalHeight / targetHeight;
        return (scaleX > scaleY ? scaleX : scaleY).ceil();
    }
  }

  @override
  Future<ImageInfo?> getImageInfo(String imagePath) async {
    try {
      final file = File(imagePath);
      if (!await file.exists()) {
        return null;
      }

      final fileSize = await file.length();
      final extension = file.path.split('.').last.toLowerCase();
      
      return ImageInfo(
        width: 0, // 需要从其他地方获取
        height: 0, // 需要从其他地方获取
        format: extension,
        fileSize: fileSize,
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<ImageProcessingResult>> batchProcess(
    List<String> imagePaths,
    ProcessingOptions options,
  ) async {
    final results = <ImageProcessingResult>[];
    
    for (final imagePath in imagePaths) {
      final result = await process(imagePath, options);
      if (result != null) {
        results.add(result);
      }
    }
    
    return results;
  }
} 