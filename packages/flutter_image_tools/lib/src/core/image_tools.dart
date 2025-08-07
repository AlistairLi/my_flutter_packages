import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

class FlutterImageTools {
  Future<ui.Size> getImageSize(String filePath) async {
    final file = File(filePath);
    final bytes = await file.readAsBytes();

    final completer = Completer<ui.Size>();
    ui.decodeImageFromList(bytes, (ui.Image img) {
      completer.complete(ui.Size(img.width.toDouble(), img.height.toDouble()));
    });
    return completer.future;
  }
}
