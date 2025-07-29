import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';

import '../flutter_image_tools_base.dart';

/// 图像旋转器
class Rotator implements ImageProcessor {
  const Rotator();

  @override
  Future<ImageProcessingResult?> process(
    String imagePath,
    ProcessingOptions options,
  ) async {
    if (options is! RotationOptions) {
      throw ArgumentError('Options must be RotationOptions');
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

      // 计算旋转角度（标准化到0-360度）
      final normalizedAngle = options.angle % 360;
      
      // 如果角度是0度，直接返回原图
      if (normalizedAngle == 0) {
        final bytes = await file.readAsBytes();
        return ImageProcessingResult(
          data: bytes,
          format: originalInfo.format,
          width: originalInfo.width,
          height: originalInfo.height,
          fileSize: originalInfo.fileSize,
        );
      }

      // 执行旋转
      // 注意：flutter_image_compress 不直接支持旋转
      // 这里需要结合其他库或原生方法实现
      // 暂时返回原图，实际实现需要添加旋转功能
      final rotatedData = await FlutterImageCompress.compressWithFile(
        imagePath,
        format: CompressFormat.jpeg,
        quality: 100,
        inSampleSize: 1,
      );

      if (rotatedData != null) {
        // 根据旋转角度计算新的宽高
        final isVertical = normalizedAngle == 90 || normalizedAngle == 270;
        final newWidth = isVertical ? originalInfo.height : originalInfo.width;
        final newHeight = isVertical ? originalInfo.width : originalInfo.height;

        return ImageProcessingResult(
          data: rotatedData,
          format: 'jpeg',
          width: newWidth,
          height: newHeight,
          fileSize: rotatedData.length,
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