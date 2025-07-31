import 'dart:io';

import 'package:path/path.dart' as path;

/// 文件操作工具
class FileOperations {
  FileOperations._();

  /// 检查文件是否存在
  static Future<bool> exists(String filePath) async {
    try {
      final file = File(filePath);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  /// 获取文件大小
  static Future<int> getFileSize(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File not found: $filePath');
      }
      return await file.length();
    } catch (e) {
      throw Exception('Failed to get file size: $e');
    }
  }

  /// 获取文件修改时间
  static Future<DateTime> getFileModifiedTime(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File not found: $filePath');
      }
      return await file.lastModified();
    } catch (e) {
      throw Exception('Failed to get file modified time: $e');
    }
  }

  /// 获取文件创建时间
  static Future<DateTime> getFileCreatedTime(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File not found: $filePath');
      }
      return await file.stat().then((stat) => stat.changed);
    } catch (e) {
      throw Exception('Failed to get file created time: $e');
    }
  }

  /// 检查文件是否可读
  static Future<bool> isReadable(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return false;

      // 尝试读取文件头来判断是否可读
      await file.openRead().take(1).toList();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 检查文件是否可写
  static Future<bool> isWritable(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        // 如果文件不存在，检查目录是否可写
        final directory = path.dirname(filePath);
        final dir = Directory(directory);
        return await dir.exists();
      }

      // 尝试写入一个字节来判断是否可写
      final tempContent = await file.readAsBytes();
      await file.writeAsBytes(tempContent);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 删除文件
  static Future<void> deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      throw Exception('Failed to delete file: $e');
    }
  }

  /// 复制文件
  static Future<void> copyFile(String sourcePath, String targetPath) async {
    try {
      final sourceFile = File(sourcePath);
      if (!await sourceFile.exists()) {
        throw Exception('Source file not found: $sourcePath');
      }

      final targetFile = File(targetPath);
      await targetFile.parent.create(recursive: true);
      await sourceFile.copy(targetPath);
    } catch (e) {
      throw Exception('Failed to copy file: $e');
    }
  }

  /// 移动文件
  static Future<void> moveFile(String sourcePath, String targetPath) async {
    try {
      final sourceFile = File(sourcePath);
      if (!await sourceFile.exists()) {
        throw Exception('Source file not found: $sourcePath');
      }

      final targetFile = File(targetPath);
      await targetFile.parent.create(recursive: true);
      await sourceFile.rename(targetPath);
    } catch (e) {
      throw Exception('Failed to move file: $e');
    }
  }
}
