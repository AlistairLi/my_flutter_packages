import 'dart:convert';

/// 文件编码器
class FileEncoder {
  FileEncoder._();

  /// Base64编码
  static String encodeBase64(List<int> bytes) {
    try {
      return base64Encode(bytes);
    } catch (e) {
      throw Exception('Failed to encode base64: $e');
    }
  }

  /// Base64解码
  static List<int> decodeBase64(String encoded) {
    try {
      return base64Decode(encoded);
    } catch (e) {
      throw Exception('Failed to decode base64: $e');
    }
  }

  /// URL安全的Base64编码
  static String encodeBase64Url(List<int> bytes) {
    try {
      return base64Url.encode(bytes);
    } catch (e) {
      throw Exception('Failed to encode base64url: $e');
    }
  }

  /// URL安全的Base64解码
  static List<int> decodeBase64Url(String encoded) {
    try {
      return base64Url.decode(encoded);
    } catch (e) {
      throw Exception('Failed to decode base64url: $e');
    }
  }

  // /// Hex编码
  // static String encodeHex(List<int> bytes) {
  //   try {
  //     return hex.encode(bytes);
  //   } catch (e) {
  //     throw Exception( 'Failed to encode hex: $e');
  //   }
  // }
  //
  // /// Hex解码
  // static List<int> decodeHex(String encoded) {
  //   try {
  //     return hex.decode(encoded);
  //   } catch (e) {
  //     throw Exception( 'Failed to decode hex: $e');
  //   }
  // }

  /// 字符串转字节数组
  static List<int> stringToBytes(String text, Encoding encoding) {
    try {
      return encoding.encode(text);
    } catch (e) {
      throw Exception('Failed to convert string to bytes: $e');
    }
  }

  /// 字节数组转字符串
  static String bytesToString(List<int> bytes, Encoding encoding) {
    try {
      return encoding.decode(bytes);
    } catch (e) {
      throw Exception('Failed to convert bytes to string: $e');
    }
  }
}
