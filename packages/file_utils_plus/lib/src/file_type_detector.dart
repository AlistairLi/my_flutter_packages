import 'package:mime/mime.dart';

/// 文件类型检测器
class FileTypeDetector {
  FileTypeDetector._();

  static String? getMimeType(String path) {
    return lookupMimeType(path);
  }
}
