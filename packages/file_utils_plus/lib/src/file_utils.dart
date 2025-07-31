import 'dart:convert';
import 'dart:io';

import 'package:file_utils_plus/src/file_type_detector.dart';

class FileUtils {
  FileUtils._();

  /// 将文件转为 base64 字符串，自动添加 MIME 头
  static Future<String> toBase64WithHeader(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) throw Exception('文件不存在: $filePath');
    final bytes = await file.readAsBytes();
    final base64Str = base64Encode(bytes);
    final mimeType =
        FileTypeDetector.getMimeType(filePath) ?? 'application/octet-stream';
    return getBase64WithHeader(mimeType, base64Str);
  }

  /// 获取Base64字符串, 自动添加 MIME 头
  static String getBase64WithHeader(String mimeType, String base64Str) {
    return 'data:$mimeType;base64,$base64Str';
  }
}
