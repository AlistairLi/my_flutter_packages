import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;

/// 文件写入器
class FileWriter {
  FileWriter._();

  /// 写入文本文件
  static Future<void> writeText(String filePath, String content) async {
    try {
      final file = File(filePath);
      await _ensureDirectoryExists(filePath);
      await file.writeAsString(content);
    } catch (e) {
      throw Exception('Failed to write text: $e');
    }
  }

  /// 写入文本文件（指定编码）
  static Future<void> writeTextWithEncoding(
      String filePath, String content, Encoding encoding) async {
    try {
      final file = File(filePath);
      await _ensureDirectoryExists(filePath);
      await file.writeAsString(content, encoding: encoding);
    } catch (e) {
      throw Exception('Failed to write text with encoding: $e');
    }
  }

  /// 写入二进制文件
  static Future<void> writeBytes(String filePath, List<int> bytes) async {
    try {
      final file = File(filePath);
      await _ensureDirectoryExists(filePath);
      await file.writeAsBytes(bytes);
    } catch (e) {
      throw Exception('Failed to write bytes: $e');
    }
  }

  /// 追加写入文本
  static Future<void> appendText(String filePath, String content) async {
    try {
      final file = File(filePath);
      await _ensureDirectoryExists(filePath);
      await file.writeAsString(content, mode: FileMode.append);
    } catch (e) {
      throw Exception('Failed to append text: $e');
    }
  }

  /// 原子写入（先写入临时文件，再重命名）
  static Future<void> writeAtomically(String filePath, List<int> data) async {
    try {
      final tempPath = '$filePath.tmp';
      final tempFile = File(tempPath);

      await _ensureDirectoryExists(filePath);
      await tempFile.writeAsBytes(data);
      await tempFile.rename(filePath);
    } catch (e) {
      throw Exception('Failed to write atomically: $e');
    }
  }

  /// 写入JSON文件
  static Future<void> writeJson(
      String filePath, Map<String, dynamic> data) async {
    try {
      final jsonString = jsonEncode(data);
      await writeText(filePath, jsonString);
    } catch (e) {
      throw Exception('Failed to write JSON: $e');
    }
  }

  /// 写入JSON文件（对象）
  static Future<void> writeJsonObject(String filePath, Object data) async {
    try {
      final jsonString = jsonEncode(data);
      await writeText(filePath, jsonString);
    } catch (e) {
      throw Exception('Failed to write JSON object: $e');
    }
  }

  /// 确保目录存在
  static Future<void> _ensureDirectoryExists(String filePath) async {
    final directory = path.dirname(filePath);
    final dir = Directory(directory);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
  }
}
