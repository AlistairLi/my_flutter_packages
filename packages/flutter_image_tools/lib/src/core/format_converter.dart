import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';

import '../flutter_image_tools_base.dart';

/// 图像格式转换器
class FormatConverter implements ImageProcessor {
  const FormatConverter();

  @override
  Future<ImageProcessingResult?> process(
    String imagePath,
    ProcessingOptions options,
  ) async {
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

      // 转换格式
      final convertedData = await FlutterImageCompress.compressWithFile(
        imagePath,
        format: _getCompressFormat(options.format),
        quality: options.quality,
        inSampleSize: 1, // 保持原始尺寸
      );

      if (convertedData != null) {
        return ImageProcessingResult(
          data: convertedData,
          format: options.format,
          width: originalInfo.width,
          height: originalInfo.height,
          fileSize: convertedData.length,
        );
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// 获取压缩格式
  CompressFormat _getCompressFormat(String format) {
    switch (format.toLowerCase()) {
      case 'jpeg':
      case 'jpg':
        return CompressFormat.jpeg;
      case 'png':
        return CompressFormat.png;
      case 'webp':
        return CompressFormat.webp;
      default:
        return CompressFormat.jpeg;
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