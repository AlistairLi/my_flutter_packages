import 'dart:typed_data';

/// 文件大小常量
class FileSize {
  // 基础单位
  static const int oneB = 1;
  static const int oneKB = 1024;
  static const int oneMB = 1024 * oneKB;
  static const int oneGB = 1024 * oneMB;
  static const int oneTB = 1024 * oneGB;

  // 常用大小
  static const int smallImage = 100 * oneKB; // 100KB
  static const int mediumImage = 500 * oneKB; // 500KB
  static const int largeImage = 1 * oneMB; // 1MB
  static const int extraLargeImage = 5 * oneMB; // 5MB
  static const int hugeImage = 10 * oneMB; // 10MB

  // 压缩阈值
  static const int compressThreshold = 1 * oneMB; // 1MB
  static const int maxUploadSize = 10 * oneMB; // 10MB
  static const int avatarSize = 200 * oneKB; // 200KB
  static const int thumbnailSize = 50 * oneKB; // 50KB

  // 格式转换阈值
  static const int webpThreshold = 500 * oneKB; // 500KB
  static const int pngThreshold = 2 * oneMB; // 2MB
}

/// 图像处理结果
class ImageProcessingResult {
  final Uint8List data;
  final String? format;
  final int width;
  final int height;
  final int fileSize;

  const ImageProcessingResult({
    required this.data,
    this.format,
    required this.width,
    required this.height,
    required this.fileSize,
  });
}

/// 图像信息
class ImageInfo {
  final int width;
  final int height;
  final String format;
  final int fileSize;
  final Map<String, dynamic>? metadata;

  const ImageInfo({
    required this.width,
    required this.height,
    required this.format,
    required this.fileSize,
    this.metadata,
  });
}

/// 处理选项基类
abstract class ProcessingOptions {
  const ProcessingOptions();
}

/// 压缩选项
class CompressionOptions extends ProcessingOptions {
  final int targetSize;
  final int quality;
  final String format;
  final bool maintainAspectRatio;
  final int maxAttempts;
  final int minQuality;
  final int qualityStep;

  const CompressionOptions({
    this.targetSize = FileSize.compressThreshold,
    this.quality = 80,
    this.format = 'jpeg',
    this.maintainAspectRatio = true,
    this.maxAttempts = 15,
    this.minQuality = 30,
    this.qualityStep = 15,
  });
}

/// 裁剪选项
class CropOptions extends ProcessingOptions {
  final double x;
  final double y;
  final double width;
  final double height;

  const CropOptions({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });
}

/// 缩放选项
class ResizeOptions extends ProcessingOptions {
  final int targetWidth;
  final int targetHeight;
  final bool maintainAspectRatio;
  final String fitMode; // 'contain', 'cover', 'fill'

  const ResizeOptions({
    required this.targetWidth,
    required this.targetHeight,
    this.maintainAspectRatio = true,
    this.fitMode = 'contain',
  });
}

/// 旋转选项
class RotationOptions extends ProcessingOptions {
  final double angle; // 角度，0-360

  const RotationOptions({required this.angle});
}

/// 水印配置
class WatermarkConfig extends ProcessingOptions {
  final String watermarkPath;
  final double x;
  final double y;
  final double opacity;
  final double scale;

  const WatermarkConfig({
    required this.watermarkPath,
    required this.x,
    required this.y,
    this.opacity = 1.0,
    this.scale = 1.0,
  });
}

/// 圆角选项
class RoundCornerOptions extends ProcessingOptions {
  final double radius;
  final bool clipToCircle;

  const RoundCornerOptions({
    this.radius = 8.0,
    this.clipToCircle = false,
  });
}

/// 边框选项
class BorderOptions extends ProcessingOptions {
  final double width;
  final String color;
  final String style; // 'solid', 'dashed', 'dotted'

  const BorderOptions({
    this.width = 1.0,
    this.color = '#000000',
    this.style = 'solid',
  });
}

/// 滤镜选项
class FilterOptions extends ProcessingOptions {
  final double brightness;
  final double contrast;
  final double saturation;
  final double hue;

  const FilterOptions({
    this.brightness = 0.0,
    this.contrast = 1.0,
    this.saturation = 1.0,
    this.hue = 0.0,
  });
}

/// 图像处理工具接口
abstract class ImageProcessor {
  /// 处理图像
  Future<ImageProcessingResult?> process(
    String imagePath,
    ProcessingOptions options,
  );

  /// 获取图像信息
  Future<ImageInfo?> getImageInfo(String imagePath);

  /// 批量处理
  Future<List<ImageProcessingResult>> batchProcess(
    List<String> imagePaths,
    ProcessingOptions options,
  );
}
