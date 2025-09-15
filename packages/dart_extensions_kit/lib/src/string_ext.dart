import 'package:flutter/material.dart';

/// String 的扩展方法
extension StringExtensions on String {
  /// 检查是否为空或只包含空白字符
  /// 字符串为 null、空字符串 ""，或者只包含空白字符（如空格、制表符、换行符等）时，返回 true
  bool get isBlank => trim().isEmpty;

  /// 检查是否不为空且不只包含空白字符
  bool get isNotBlank => !isBlank;

  /// 检查字符串是否为 "null"（不区分大小写）
  /// 包括："null"、"NULL"、"Null" 等
  bool get isNullString => toLowerCase() == 'null';

  /// 首字母大写
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// 首字母小写
  String get unCapitalize {
    if (isEmpty) return this;
    return '${this[0].toLowerCase()}${substring(1)}';
  }

  /// 驼峰命名转下划线
  String get toSnakeCase {
    return replaceAllMapped(
      RegExp(r'[A-Z]'),
      (Match match) => '_${match.group(0)!.toLowerCase()}',
    ).replaceFirst(RegExp(r'^_'), '');
  }

  /// 下划线转驼峰命名
  String get toCamelCase {
    return replaceAllMapped(
      RegExp(r'_([a-z])'),
      (Match match) => match.group(1)!.toUpperCase(),
    );
  }

  /// 截取指定长度，超出部分用省略号
  String truncate(int maxLength, {String suffix = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}$suffix';
  }

  /// 移除HTML标签
  String get removeHtmlTags {
    return replaceAll(RegExp(r'<[^>]*>'), '');
  }

  /// 检查是否为邮箱格式
  bool get isEmail {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);
  }

  /// 检查是否为手机号格式（中国）
  bool get isPhoneNumber {
    return RegExp(r'^1[3-9]\d{9}$').hasMatch(this);
  }

  /// 检查是否为URL格式
  bool get isUrl {
    return RegExp(r'^https?://').hasMatch(this);
  }

  /// 转换为 int
  int? tryToInt() {
    return int.tryParse(trim());
  }

  /// 转换为 double
  double? tryToDouble() {
    return double.tryParse(trim());
  }

  /// 转换为颜色
  Color? get toColor {
    if (startsWith('#')) {
      final hex = substring(1);
      if (hex.length == 3) {
        // 处理 3 位十六进制
        final r = hex[0] * 2;
        final g = hex[1] * 2;
        final b = hex[2] * 2;
        return Color(int.parse('FF$r$g$b', radix: 16));
      } else if (hex.length == 6) {
        // 处理 6 位十六进制
        return Color(int.parse('FF$hex', radix: 16));
      } else if (hex.length == 8) {
        // 处理 8 位十六进制（包含透明度）
        return Color(int.parse(hex, radix: 16));
      }
    }
    return null;
  }

  /// 反转字符串
  String get reversed => split('').reversed.join();

  /// 重复字符串
  /// [times] 重复次数
  String repeat(int times) {
    return List.filled(times, this).join();
  }

  /// 移除指定字符
  String remove(String char) {
    return replaceAll(char, '');
  }

  /// 移除多个字符
  String removeAll(List<String> chars) {
    String result = this;
    for (final char in chars) {
      result = result.replaceAll(char, '');
    }
    return result;
  }

  /// 检查是否包含数字
  bool get containsNumber {
    return RegExp(r'\d').hasMatch(this);
  }

  /// 检查是否只包含数字
  bool get isNumeric {
    return RegExp(r'^\d+$').hasMatch(this);
  }

  /// 检查是否只包含字母
  bool get isAlphabetic {
    return RegExp(r'^[a-zA-Z]+$').hasMatch(this);
  }

  /// 检查是否只包含字母和数字
  bool get isAlphanumeric {
    return RegExp(r'^[a-zA-Z0-9]+$').hasMatch(this);
  }
}

extension NullableStringExtensions on String? {
  /// 转换为 int, 如果失败返回指定默认值
  int toIntOr(int defaultValue) {
    if (this == null) return defaultValue;
    return int.tryParse(this!.trim()) ?? defaultValue;
  }

  /// 转换为 double, 如果失败返回指定默认值
  double toDoubleOr(double defaultValue) {
    if (this == null) return defaultValue;
    return double.tryParse(this!.trim()) ?? defaultValue;
  }
}

extension StringExtensions2 on String? {
  bool get isNullOrEmpty => this == null || this!.isEmpty;

  bool get isNotNullOrEmpty => !isNullOrEmpty;

  bool get isNullOrBlank => this == null || this!.isBlank;

  bool get isNotNullOrBlank => !isNullOrBlank;

  /// 宽松解析，只要是 "true"（忽略大小写）返回 true，其他都为 false
  bool get toBool => this?.toLowerCase() == 'true';

  /// 严格解析，只接受 "true" 或 "false"（忽略大小写），否则抛异常
  bool toBoolStrict() {
    final lower = this?.toLowerCase();
    if (lower == 'true') return true;
    if (lower == 'false') return false;
    throw FormatException('Invalid boolean string: "$this"');
  }
}

extension EnumParsing on String {
  /// 解析字符串为枚举值，匹配 enum 的 name
  ///
  /// [values] 枚举值列表
  /// [defaultValue] 找不到时返回的默认值，默认为 null
  /// [ignoreCase] 是否忽略大小写，默认为 false
  T? toEnum<T extends Enum>(List<T> values,
      {T? defaultValue, bool ignoreCase = false}) {
    final match = values.where((e) {
      final enumName = e.name;
      if (ignoreCase) {
        return enumName.toLowerCase() == toLowerCase();
      } else {
        return enumName == this;
      }
    });

    return match.isNotEmpty ? match.first : defaultValue;
  }
}

extension EnumParsing2 on String? {
  T toEnumOr<T extends Enum>(List<T> values, T defaultValue,
      {bool ignoreCase = false}) {
    if (this == null) return defaultValue;
    return this!.toEnum(values,
            defaultValue: defaultValue, ignoreCase: ignoreCase) ??
        defaultValue;
  }
}
