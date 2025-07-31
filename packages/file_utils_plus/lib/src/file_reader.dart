import 'dart:convert';
import 'dart:io';

/// 文件读取器
class FileReader {
  FileReader._();

  /// 读取文本文件
  static Future<String> readText(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File not found: $filePath');
      }
      return await file.readAsString();
    } catch (e) {
      throw Exception('Failed to read file: $e');
    }
  }

  /// 读取文本文件（指定编码）
  static Future<String> readTextWithEncoding(
      String filePath, Encoding encoding) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File not found: $filePath');
      }
      return await file.readAsString(encoding: encoding);
    } catch (e) {
      throw Exception('Failed to read file with encoding: $e');
    }
  }

  /// 读取二进制文件
  static Future<List<int>> readBytes(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File not found: $filePath');
      }
      return await file.readAsBytes();
    } catch (e) {
      throw Exception('Failed to read bytes: $e');
    }
  }

  /// 流式读取大文件
  static Stream<List<int>> readAsStream(String filePath) {
    try {
      final file = File(filePath);
      return file.openRead();
    } catch (e) {
      throw Exception('Failed to read file as stream: $e');
    }
  }

  /// 分块读取大文件
  static Future<void> readInChunks(
      String filePath, int chunkSize, Function(List<int>) onChunk) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File not found: $filePath');
      }

      final stream = file.openRead();
      await for (final chunk in stream) {
        onChunk(chunk);
      }
    } catch (e) {
      throw Exception('Failed to read file in chunks: $e');
    }
  }

  /// 读取JSON文件
  static Future<Map<String, dynamic>> readJson(String filePath) async {
    try {
      final content = await readText(filePath);
      return jsonDecode(content) as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to read JSON: $e');
    }
  }

  /// 读取JSON文件（泛型）
  static Future<T> readJsonAs<T>(
      String filePath, T Function(Map<String, dynamic>) fromJson) async {
    try {
      final json = await readJson(filePath);
      return fromJson(json);
    } catch (e) {
      throw Exception('Failed to read JSON as type: $e');
    }
  }
}
