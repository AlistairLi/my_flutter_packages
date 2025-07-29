import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';

import '../flutter_image_tools_base.dart';

/// 智能图像压缩器
class SmartCompressor implements ImageProcessor {
  const SmartCompressor();

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

      // 检查是否需要压缩
      if (originalInfo.fileSize <= options.targetSize) {
        // 如果文件已经小于目标大小，直接返回
        final bytes = await file.readAsBytes();
        return ImageProcessingResult(
          data: bytes,
          format: originalInfo.format,
          width: originalInfo.width,
          height: originalInfo.height,
          fileSize: originalInfo.fileSize,
        );
      }

      // 智能压缩策略
      return await _compressWithStrategy2(imagePath, options, originalInfo);
    } catch (e) {
      return null;
    }
  }

  /// 不断压缩图片直到达到指定大小
  /// 使用交替压缩策略
  @Deprecated("")
  static Future<ImageProcessingResult?> _compressWithStrategy(
    String imagePath,
    CompressionOptions options,
    ImageInfo originalInfo,
  ) async {
    try {
      final file = File(imagePath);
      if (!await file.exists()) {
        return null;
      }

      // 第一步：检查并压缩尺寸到指定像素
      var currentSampleSize = 1;
      var currentQuality = 100;
      int attempts = 0;
      int qualityAttempts = 0;
      const maxQualityAttempts = 3; // 质量压缩最多尝试3次

      // 先通过尺寸压缩到合适的大小
      while (attempts < options.maxAttempts && currentSampleSize <= 16) {
        try {
          final compressedData = await FlutterImageCompress.compressWithFile(
            imagePath,
            format: CompressFormat.jpeg,
            quality: currentQuality,
            inSampleSize: currentSampleSize,
          );

          // 计算新的尺寸
          final newWidth = originalInfo.width ~/ currentSampleSize;
          final newHeight = originalInfo.height ~/ currentSampleSize;
          if (compressedData != null) {
            // 检查是否达到目标大小
            if (compressedData.length <= options.targetSize) {
              return ImageProcessingResult(
                data: compressedData,
                format: options.format,
                width: newWidth,
                height: newHeight,
                fileSize: compressedData.length,
              );
            }

            // 如果还是太大，先尝试质量压缩
            qualityAttempts = 0;
            var tempQuality = currentQuality;

            while (qualityAttempts < maxQualityAttempts &&
                tempQuality >= options.minQuality) {
              try {
                final qualityCompressedData =
                    await FlutterImageCompress.compressWithFile(
                  imagePath,
                  format: CompressFormat.jpeg,
                  quality: tempQuality,
                  inSampleSize: currentSampleSize,
                );

                if (qualityCompressedData != null &&
                    qualityCompressedData.length <= options.targetSize) {
                  return ImageProcessingResult(
                    data: compressedData,
                    format: options.format,
                    width: newWidth,
                    height: newHeight,
                    fileSize: compressedData.length,
                  );
                }

                tempQuality -= options.qualityStep;
                qualityAttempts++;
              } catch (e) {
                tempQuality -= options.qualityStep;
                qualityAttempts++;
              }
            }

            // 如果质量压缩后还是太大，增加尺寸压缩
            currentSampleSize *= 2;
            currentQuality = 100; // 重置质量
          }
        } catch (e) {
          currentSampleSize *= 2;
          currentQuality = 100;
        }

        attempts++;
      }

      // 如果还是无法达到目标大小，使用最大压缩
      try {
        var maxCompressedData = await FlutterImageCompress.compressWithFile(
          imagePath,
          format: CompressFormat.jpeg,
          quality: options.minQuality,
          inSampleSize: 16,
        );
        final newWidth = originalInfo.width ~/ 16;
        final newHeight = originalInfo.height ~/ 16;
        if (maxCompressedData != null) {
          return ImageProcessingResult(
            data: maxCompressedData,
            format: options.format,
            width: newWidth,
            height: newHeight,
            fileSize: maxCompressedData.length,
          );
        }
        return null;
      } catch (e) {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  /// 智能压缩策略2
  Future<ImageProcessingResult?> _compressWithStrategy2(
    String imagePath,
    CompressionOptions options,
    ImageInfo originalInfo,
  ) async {
    // 第一步：质量压缩
    var currentQuality = 100;
    var currentSampleSize = 1;
    const maxQualityAttempts = 3;
    const maxSampleSize = 16;

    while (currentSampleSize <= maxSampleSize) {
      // 在当前尺寸下尝试质量压缩
      for (int qualityAttempt = 0;
          qualityAttempt < maxQualityAttempts;
          qualityAttempt++) {
        try {
          final compressedData = await FlutterImageCompress.compressWithFile(
            imagePath,
            format: _getCompressFormat(options.format),
            quality: currentQuality,
            inSampleSize: currentSampleSize,
          );

          if (compressedData != null &&
              compressedData.length <= options.targetSize) {
            // 计算新的尺寸
            final newWidth = originalInfo.width ~/ currentSampleSize;
            final newHeight = originalInfo.height ~/ currentSampleSize;

            return ImageProcessingResult(
              data: compressedData,
              format: options.format,
              width: newWidth,
              height: newHeight,
              fileSize: compressedData.length,
            );
          }

          // 降低质量继续尝试
          currentQuality = (currentQuality - 15).clamp(10, 100);
        } catch (e) {
          currentQuality = (currentQuality - 15).clamp(10, 100);
        }
      }

      // 质量压缩无法达到目标，增加尺寸压缩
      currentSampleSize *= 2;
      currentQuality = 100; // 重置质量
    }

    // 如果还是无法达到目标大小，使用最大压缩
    try {
      final finalCompressedData = await FlutterImageCompress.compressWithFile(
        imagePath,
        format: _getCompressFormat(options.format),
        quality: 10, // 最低质量
        inSampleSize: 16, // 最大压缩
      );

      if (finalCompressedData != null) {
        final newWidth = originalInfo.width ~/ 16;
        final newHeight = originalInfo.height ~/ 16;

        return ImageProcessingResult(
          data: finalCompressedData,
          format: options.format,
          width: newWidth,
          height: newHeight,
          fileSize: finalCompressedData.length,
        );
      }
    } catch (e) {
      return null;
    }

    return null;
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

      // 使用 flutter_image_compress 获取图像信息
      final compressedData = await FlutterImageCompress.compressWithFile(
        imagePath,
        format: CompressFormat.jpeg,
        quality: 100,
        inSampleSize: 1,
      );

      if (compressedData != null) {
        // 这里需要获取实际的宽高信息
        // 由于 flutter_image_compress 不直接提供宽高信息，
        // 我们可以通过其他方式获取，或者使用默认值
        return ImageInfo(
          width: 0, // 需要从其他地方获取
          height: 0, // 需要从其他地方获取
          format: 'jpeg',
          fileSize: fileSize,
        );
      }

      return null;
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

  /// 判断图片是否需要压缩
  /// 返回 true 表示需要压缩，false 表示不需要压缩
  Future<bool> shouldCompress(String filePath,
      {int threshold = FileSize.compressThreshold}) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        final fileSize = await file.length();
        return fileSize > threshold;
      }
    } catch (e) {
      // 发生异常时，默认不压缩
      return false;
    }
    return false;
  }
}
