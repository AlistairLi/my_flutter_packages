import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_watermark_plus/flutter_watermark_plus.dart';
import 'package:flutter_watermark_plus/src/engine/canvas_watermark_engine.dart';
import 'package:flutter_watermark_plus/src/engine/watermark_engine.dart';
import 'package:path_provider/path_provider.dart';

class WatermarkProcessor {
  final IWatermarkEngine engine;

  WatermarkProcessor({IWatermarkEngine? engine})
      : engine = engine ?? CanvasWatermarkEngine(); // 默认用Canvas

  Future<Uint8List> addWatermark({
    required Uint8List imageBytes,
    required String text,
    Config config = const Config(),
  }) {
    return engine.applyWatermark(
      imageBytes: imageBytes,
      text: text,
      config: config,
    );
  }

  Future<String> addWatermarkToFilePath({
    required String inputPath,
    required String text,
    Config config = const Config(),
    bool overwrite = false,
  }) async {
    final inputFile = File(inputPath);
    if (!await inputFile.exists()) {
      throw Exception('Input file does not exist: $inputPath');
    }

    final imageBytes = await inputFile.readAsBytes();
    final processedBytes = await addWatermark(
      imageBytes: imageBytes,
      text: text,
      config: config,
    );

    final tempDir = await getTemporaryDirectory();
    final outputPath =
        overwrite ? inputPath : '${tempDir.path}/${_getFileName(inputPath)}';
    final outputFile = File(outputPath);
    await outputFile.writeAsBytes(processedBytes);
    return outputPath;
  }

  String _getFileName(String path) {
    // final lastSlashIndex = path.lastIndexOf('/');
    // return path.substring(lastSlashIndex + 1);
    var sinceEpoch = DateTime.now().millisecondsSinceEpoch;
    return 'watermark_$sinceEpoch.png';
  }
}
