import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';

import '../flutter_image_tools_base.dart';

/// 图像方向修正器
class OrientationFixer implements ImageProcessor {
  const OrientationFixer();

  @override
  Future<ImageProcessingResult?> process(
    String imagePath,
    ProcessingOptions options,
  ) async {
    // 方向修正不需要特殊选项，使用默认的压缩选项
    if (options is! CompressionOptions) {
      throw ArgumentError('Options must be CompressionOptions');
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

      // 执行方向修正
      // 注意：flutter_image_compress 不直接支持方向修正
      // 这里需要结合其他库或原生方法实现
      // 暂时返回原图，实际实现需要添加方向修正功能
      final fixedData = await FlutterImageCompress.compressWithFile(
        imagePath,
        format: CompressFormat.jpeg,
        quality: options.quality,
        inSampleSize: 1,
      );

      if (fixedData != null) {
        return ImageProcessingResult(
          data: fixedData,
          format: 'jpeg',
          width: originalInfo.width,
          height: originalInfo.height,
          fileSize: fixedData.length,
        );
      }

      return null;
    } catch (e) {
      return null;
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