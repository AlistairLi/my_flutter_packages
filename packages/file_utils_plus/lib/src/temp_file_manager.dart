import 'dart:io';

import 'package:path/path.dart' as path;

/// 临时文件管理器
class TempFileManager {
  TempFileManager._();

  static final List<String> _tempFiles = [];

  /// 创建临时文件
  static Future<String> createTempFile(String prefix, String suffix) async {
    try {
      final tempDir = await Directory.systemTemp.createTemp('file_utils_plus_');
      final tempFile = File(path.join(tempDir.path, '$prefix$suffix'));
      await tempFile.create();

      _tempFiles.add(tempFile.path);
      return tempFile.path;
    } catch (e) {
      throw Exception('Failed to create temp file: $e');
    }
  }

  /// 创建临时目录
  static Future<String> createTempDirectory(String prefix) async {
    try {
      final tempDir =
          await Directory.systemTemp.createTemp('file_utils_plus_$prefix');
      _tempFiles.add(tempDir.path);
      return tempDir.path;
    } catch (e) {
      throw Exception('Failed to create temp directory: $e');
    }
  }

  /// 清理所有临时文件
  static Future<void> cleanupAllTempFiles() async {
    for (final tempPath in _tempFiles) {
      try {
        final file = File(tempPath);
        final dir = Directory(tempPath);

        if (await file.exists()) {
          await file.delete();
        } else if (await dir.exists()) {
          await dir.delete(recursive: true);
        }
      } catch (e) {
        // 忽略清理错误
      }
    }
    _tempFiles.clear();
  }

  /// 清理指定临时文件
  static Future<void> cleanupTempFile(String tempPath) async {
    try {
      final file = File(tempPath);
      final dir = Directory(tempPath);

      if (await file.exists()) {
        await file.delete();
      } else if (await dir.exists()) {
        await dir.delete(recursive: true);
      }

      _tempFiles.remove(tempPath);
    } catch (e) {
      throw Exception('Failed to cleanup temp file: $e');
    }
  }

  /// 获取临时文件列表
  static List<String> getTempFiles() {
    return List.unmodifiable(_tempFiles);
  }
}
