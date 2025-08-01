import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:flutter_watermark_plus/flutter_watermark_plus.dart';
import 'package:flutter_watermark_plus/src/engine/watermark_engine.dart';
import 'package:flutter_watermark_plus/src/utils/watermark_painter_util.dart';

/// Canvas-based watermark engine implementation
///
/// This engine applies watermarks to images using canvas drawing operations.
/// It uses the common watermark drawing utility for consistent behavior.
class CanvasWatermarkEngine implements IWatermarkEngine {
  @override
  Future<Uint8List> applyWatermark({
    required Uint8List imageBytes,
    required String text,
    required Config config,
  }) async {
    final codec = await ui.instantiateImageCodec(imageBytes);
    final frame = await codec.getNextFrame();
    final image = frame.image;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Draw the original image
    canvas.drawImage(image, Offset.zero, Paint());

    // Draw watermark using the common utility
    WatermarkPainterUtil.drawWatermarkPatternOnFlutterCanvas(
      canvas: canvas,
      size: Size(image.width.toDouble(), image.height.toDouble()),
      text: text,
      config: config,
    );

    final picture = recorder.endRecording();
    final outputImage = await picture.toImage(
      image.width,
      image.height,
    );
    final byteData = await outputImage.toByteData(
      format: ui.ImageByteFormat.png,
    );

    return byteData!.buffer.asUint8List();
  }
}
