import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';

import '../flutter_image_tools_base.dart';

/// 圆角处理器
class RoundCropper implements ImageProcessor {
  const RoundCropper();

  @override
  Future<ImageProcessingResult?> process(
    String imagePath,
    ProcessingOptions options,
  ) async {
    if (options is! RoundCornerOptions) {
      throw ArgumentError('Options must be RoundCornerOptions');
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

      // 执行圆角处理
      // 注意：flutter_image_compress 不直接支持圆角处理
      // 这里需要结合其他库或原生方法实现
      // 暂时返回原图，实际实现需要添加圆角功能
      final roundedData = await FlutterImageCompress.compressWithFile(
        imagePath,
        format: CompressFormat.png, // 使用PNG格式以支持透明度
        quality: 100,
        inSampleSize: 1,
      );

      if (roundedData != null) {
        return ImageProcessingResult(
          data: roundedData,
          format: 'png',
          width: originalInfo.width,
          height: originalInfo.height,
          fileSize: roundedData.length,
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