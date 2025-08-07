import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_image_tools/src/core/image_tools.dart';

import '../flutter_image_tools_base.dart';

/// 图像裁剪器
class Cropper implements ImageProcessor {
  const Cropper();

  @override
  Future<ImageProcessingResult?> process(
    String imagePath,
    ProcessingOptions options,
  ) async {
    if (options is! CropOptions) {
      throw ArgumentError('Options must be CropOptions');
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

      // 验证裁剪参数
      if (options.x < 0 ||
          options.y < 0 ||
          options.width <= 0 ||
          options.height <= 0 ||
          options.x + options.width > originalInfo.width ||
          options.y + options.height > originalInfo.height) {
        throw ArgumentError('Invalid crop parameters');
      }

      // 执行裁剪
      // 注意：flutter_image_compress 不直接支持裁剪
      // 这里需要结合其他库或原生方法实现
      // 暂时返回原图，实际实现需要添加裁剪功能
      final croppedData = await FlutterImageCompress.compressWithFile(
        imagePath,
        format: CompressFormat.jpeg,
        quality: 100,
        inSampleSize: 1,
      );

      if (croppedData != null) {
        return ImageProcessingResult(
          data: croppedData,
          format: 'jpeg',
          width: options.width.toInt(),
          height: options.height.toInt(),
          fileSize: croppedData.length,
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

      var imageSize = await FlutterImageTools().getImageSize(imagePath);

      final fileSize = await file.length();
      final extension = file.path.split('.').last.toLowerCase();

      return ImageInfo(
        width: imageSize.width.toInt(),
        height: imageSize.height.toInt(),
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

  /// 将图片等分成若干份
  ///
  /// [imagePath] 图片路径
  /// [pieces] 要分割的份数，必须是完全平方数（如4、9、16、25...）
  ///
  /// 返回分割后的图片列表
  Future<List<Uint8List>> splitImage(String imagePath, int pieces) async {
    // 验证分割份数是否为完全平方数
    final sqrtPieces = sqrt(pieces).toInt();
    if (sqrtPieces * sqrtPieces != pieces) {
      throw ArgumentError(
          'Pieces must be a perfect square number (4, 9, 16, 25, etc.)');
    }

    final file = File(imagePath);
    if (!await file.exists()) {
      return [];
    }

    var bytes = await file.readAsBytes();
    final Codec codec = await instantiateImageCodec(bytes);
    final FrameInfo fi = await codec.getNextFrame();
    final Image image = fi.image;

    // 获取图片宽高
    var imageSize = await FlutterImageTools().getImageSize(imagePath);

    // 计算每个子图的尺寸
    final pieceWidth = (imageSize.width / sqrtPieces).toInt();
    final pieceHeight = (imageSize.height / sqrtPieces).toInt();

    final List<Uint8List> result = [];

    for (int y = 0; y < sqrtPieces; y++) {
      for (int x = 0; x < sqrtPieces; x++) {
        final recorder = PictureRecorder();
        final canvas = Canvas(recorder);

        canvas.drawImageRect(
          image,
          Rect.fromLTWH(
            x * pieceWidth.toDouble(),
            y * pieceHeight.toDouble(),
            pieceWidth.toDouble(),
            pieceHeight.toDouble(),
          ),
          Rect.fromLTWH(
            0,
            0,
            pieceWidth.toDouble(),
            pieceHeight.toDouble(),
          ),
          Paint(),
        );

        final picture = recorder.endRecording();
        final img = await picture.toImage(pieceWidth, pieceHeight);
        final byteData = await img.toByteData(format: ImageByteFormat.png);

        result.add(byteData!.buffer.asUint8List());
      }
    }

    return result;
  }
}
