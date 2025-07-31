import 'dart:io';

import 'package:crypto/crypto.dart';

/// 文件校验器
class FileValidator {
  FileValidator._();

  /// 计算文件MD5
  static Future<String> calculateMD5(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File not found: $filePath');
      }

      final bytes = await file.readAsBytes();
      final digest = md5.convert(bytes);
      return digest.toString();
    } catch (e) {
      throw Exception('Failed to calculate MD5: $e');
    }
  }

  /// 计算文件SHA1
  static Future<String> calculateSHA1(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File not found: $filePath');
      }

      final bytes = await file.readAsBytes();
      final digest = sha1.convert(bytes);
      return digest.toString();
    } catch (e) {
      throw Exception('Failed to calculate SHA1: $e');
    }
  }

  /// 计算文件SHA256
  static Future<String> calculateSHA256(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File not found: $filePath');
      }

      final bytes = await file.readAsBytes();
      final digest = sha256.convert(bytes);
      return digest.toString();
    } catch (e) {
      throw Exception('Failed to calculate SHA256: $e');
    }
  }

  /// 验证文件完整性
  static Future<bool> verifyFileIntegrity(
      String filePath, String expectedHash, HashAlgorithm algorithm) async {
    try {
      String actualHash;
      switch (algorithm) {
        case HashAlgorithm.md5:
          actualHash = await calculateMD5(filePath);
          break;
        case HashAlgorithm.sha1:
          actualHash = await calculateSHA1(filePath);
          break;
        case HashAlgorithm.sha256:
          actualHash = await calculateSHA256(filePath);
          break;
      }

      return actualHash.toLowerCase() == expectedHash.toLowerCase();
    } catch (e) {
      return false;
    }
  }

// /// 流式计算文件哈希（适用于大文件）
// static Future<String> calculateHashStream(
//     String filePath, HashAlgorithm algorithm) async {
//   try {
//     final file = File(filePath);
//     if (!await file.exists()) {
//       throw Exception('File not found: $filePath');
//     }
//
//     final stream = file.openRead();
//     final sink = algorithm == HashAlgorithm.md5
//         ? md5.startChunkedConversion(HexEncoder())
//         : algorithm == HashAlgorithm.sha1
//             ? sha1.startChunkedConversion(HexEncoder())
//             : sha256.startChunkedConversion(HexEncoder());
//
//     await for (final chunk in stream) {
//       sink.add(chunk);
//     }
//
//     return sink.close();
//   } catch (e) {
//     throw Exception('Failed to calculate hash stream: $e');
//   }
// }
}

/// 哈希算法枚举
enum HashAlgorithm {
  md5,
  sha1,
  sha256,
}
