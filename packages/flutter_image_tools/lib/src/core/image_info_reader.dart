import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';

import '../flutter_image_tools_base.dart';

/// 图像信息读取器
class ImageInfoReader {
  const ImageInfoReader();

  /// 获取图像信息
  Future<ImageInfo?> getImageInfo(String imagePath) async {
    try {
      final file = File(imagePath);
      if (!await file.exists()) {
        return null;
      }

      final fileSize = await file.length();
      final extension = file.path.split('.').last.toLowerCase();
      
      // 尝试获取图像尺寸信息
      // 注意：flutter_image_compress 不直接提供尺寸信息
      // 这里需要结合其他库或原生方法获取
      final dimensions = await _getImageDimensions(imagePath);
      
      return ImageInfo(
        width: dimensions['width'] ?? 0,
        height: dimensions['height'] ?? 0,
        format: extension,
        fileSize: fileSize,
        metadata: await _getImageMetadata(imagePath),
      );
    } catch (e) {
      return null;
    }
  }

  /// 获取图像尺寸
  Future<Map<String, int>> _getImageDimensions(String imagePath) async {
    try {
      // 使用 flutter_image_compress 获取基本信息
      final compressedData = await FlutterImageCompress.compressWithFile(
        imagePath,
        format: CompressFormat.jpeg,
        quality: 100,
        inSampleSize: 1,
      );

      if (compressedData != null) {
        // 这里需要从其他地方获取实际的宽高信息
        // 暂时返回默认值
        return {
          'width': 0,
          'height': 0,
        };
      }

      return {
        'width': 0,
        'height': 0,
      };
    } catch (e) {
      return {
        'width': 0,
        'height': 0,
      };
    }
  }

  /// 获取图像元数据
  Future<Map<String, dynamic>?> _getImageMetadata(String imagePath) async {
    try {
      final file = File(imagePath);
      final stat = await file.stat();
      
      return {
        'created': stat.changed.toIso8601String(),
        'modified': stat.modified.toIso8601String(),
        'size': stat.size,
        'path': imagePath,
      };
    } catch (e) {
      return null;
    }
  }

  /// 批量获取图像信息
  Future<List<ImageInfo>> getBatchImageInfo(List<String> imagePaths) async {
    final results = <ImageInfo>[];
    
    for (final imagePath in imagePaths) {
      try {
        final info = await getImageInfo(imagePath);
        if (info != null) {
          results.add(info);
        }
      } catch (e) {
        print('Error getting info for $imagePath: $e');
      }
    }
    
    return results;
  }

  /// 检查图像是否有效
  Future<bool> isValidImage(String imagePath) async {
    try {
      final file = File(imagePath);
      if (!await file.exists()) {
        return false;
      }

      // 尝试压缩图像来验证其有效性
      final compressedData = await FlutterImageCompress.compressWithFile(
        imagePath,
        format: CompressFormat.jpeg,
        quality: 100,
        inSampleSize: 1,
      );

      return compressedData != null;
    } catch (e) {
      return false;
    }
  }

  /// 获取支持的图像格式
  List<String> getSupportedFormats() {
    return ['jpeg', 'jpg', 'png', 'webp'];
  }

  /// 检查格式是否支持
  bool isFormatSupported(String format) {
    final supportedFormats = getSupportedFormats();
    return supportedFormats.contains(format.toLowerCase());
  }
} 