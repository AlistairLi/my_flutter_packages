import 'dart:typed_data';

import 'package:flutter_watermark_plus/flutter_watermark_plus.dart';

abstract class IWatermarkEngine {
  Future<Uint8List> applyWatermark({
    required Uint8List imageBytes,
    required String text,
    required Config config,
  });
}
