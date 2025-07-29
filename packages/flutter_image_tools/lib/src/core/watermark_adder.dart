import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';

import '../flutter_image_tools_base.dart';

/// 水印添加器
class WatermarkAdder implements ImageProcessor {
  const WatermarkAdder();

  @override
  Future<ImageProcessingResult?> process(
    String imagePath,
    ProcessingOptions options,
  ) async {
    if (options is! WatermarkConfig) {
      throw ArgumentError('Options must be WatermarkConfig');
    }

    try {
      final file = File(imagePath);
      if (!await file.exists()) {
        return null;
      }

      // 检查水印文件是否存在
      final watermarkFile = File(options.watermarkPath);
      if (!await watermarkFile.exists()) {
        throw ArgumentError('Watermark file does not exist');
      }

      // 获取原始图像信息
      final originalInfo = await getImageInfo(imagePath);
      if (originalInfo == null) {
        return null;
      }

      // 执行水印添加
      // 注意：flutter_image_compress 不直接支持水印
      // 这里需要结合其他库或原生方法实现
      // 暂时返回原图，实际实现需要添加水印功能
      final watermarkedData = await FlutterImageCompress.compressWithFile(
        imagePath,
        format: CompressFormat.jpeg,
        quality: 100,
        inSampleSize: 1,
      );

      if (watermarkedData != null) {
        return ImageProcessingResult(
          data: watermarkedData,
          format: 'jpeg',
          width: originalInfo.width,
          height: originalInfo.height,
          fileSize: watermarkedData.length,
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