import '../flutter_image_tools_base.dart';
import 'border_adder.dart';
import 'cropper.dart';
import 'filter_applier.dart';
import 'format_converter.dart';
import 'resizer.dart';
import 'rotator.dart';
import 'round_cropper.dart';
import 'smart_compressor.dart';

/// 批量处理器
class BatchProcessor {
  const BatchProcessor();

  /// 批量处理图像
  Future<List<ImageProcessingResult>> processBatch(
    List<String> imagePaths,
    ProcessingOptions options,
    ImageProcessor processor,
  ) async {
    final results = <ImageProcessingResult>[];

    for (final imagePath in imagePaths) {
      try {
        final result = await processor.process(imagePath, options);
        if (result != null) {
          results.add(result);
        }
      } catch (e) {
        // 记录错误但继续处理其他图像
        print('Error processing $imagePath: $e');
      }
    }

    return results;
  }

  /// 批量压缩
  Future<List<ImageProcessingResult>> compressBatch(
    List<String> imagePaths,
    CompressionOptions options,
  ) async {
    return processBatch(imagePaths, options, const SmartCompressor());
  }

  /// 批量格式转换
  Future<List<ImageProcessingResult>> convertFormatBatch(
    List<String> imagePaths,
    CompressionOptions options,
  ) async {
    return processBatch(imagePaths, options, const FormatConverter());
  }

  /// 批量缩放
  Future<List<ImageProcessingResult>> resizeBatch(
    List<String> imagePaths,
    ResizeOptions options,
  ) async {
    return processBatch(imagePaths, options, const Resizer());
  }

  /// 批量旋转
  Future<List<ImageProcessingResult>> rotateBatch(
    List<String> imagePaths,
    RotationOptions options,
  ) async {
    return processBatch(imagePaths, options, const Rotator());
  }

  /// 批量裁剪
  Future<List<ImageProcessingResult>> cropBatch(
    List<String> imagePaths,
    CropOptions options,
  ) async {
    return processBatch(imagePaths, options, const Cropper());
  }

  /// 批量圆角处理
  Future<List<ImageProcessingResult>> roundCornerBatch(
    List<String> imagePaths,
    RoundCornerOptions options,
  ) async {
    return processBatch(imagePaths, options, const RoundCropper());
  }

  /// 批量添加边框
  Future<List<ImageProcessingResult>> addBorderBatch(
    List<String> imagePaths,
    BorderOptions options,
  ) async {
    return processBatch(imagePaths, options, const BorderAdder());
  }

  /// 批量应用滤镜
  Future<List<ImageProcessingResult>> applyFilterBatch(
    List<String> imagePaths,
    FilterOptions options,
  ) async {
    return processBatch(imagePaths, options, const FilterApplier());
  }
}
