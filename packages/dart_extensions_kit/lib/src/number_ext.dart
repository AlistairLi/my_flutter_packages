import 'dart:math';

import 'package:dart_extensions_kit/src/date_ext.dart';
import 'package:intl/intl.dart';

/// int 的扩展方法
extension IntExtensions on int {
  /// 检查是否为偶数
  bool get isEven => this % 2 == 0;

  /// 检查是否为奇数
  bool get isOdd => this % 2 != 0;

  /// 转换为二进制字符串
  String get toBinary => toRadixString(2);

  /// 转换为八进制字符串
  String get toOctal => toRadixString(8);

  /// 转换为十六进制字符串（大写）
  String get toHexUpperCase => toRadixString(16).toUpperCase();

  /// 转换为十六进制字符串（小写）
  String get toHexLowerCase => toRadixString(16).toLowerCase();

  /// 转换为文件大小字符串
  /// 当前数字的单位为字节
  String get toFileSize {
    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    double size = toDouble();
    int unitIndex = 0;

    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }

    return '${size.toStringAsFixed(2)} ${units[unitIndex]}';
  }

  /// 检查是否为质数
  bool get isPrime {
    if (this < 2) return false;
    if (this == 2) return true;
    if (isEven) return false;

    for (int i = 3; i * i <= this; i += 2) {
      if (this % i == 0) return false;
    }
    return true;
  }

  /// 获取阶乘
  int get factorial {
    if (this < 0) {
      throw ArgumentError('Factorial is not defined for negative numbers');
    }
    if (this == 0 || this == 1) return 1;

    int result = 1;
    for (int i = 2; i <= this; i++) {
      result *= i;
    }
    return result;
  }

  /// 获取斐波那契数
  int get fibonacci {
    if (this < 0) {
      throw ArgumentError('Fibonacci is not defined for negative numbers');
    }

    if (this <= 1) return this;

    int a = 0, b = 1;
    for (int i = 2; i <= this; i++) {
      final temp = a + b;
      a = b;
      b = temp;
    }
    return b;
  }

  /// 获取所有因子
  List<int> get factors {
    final factors = <int>[];
    for (int i = 1; i <= this; i++) {
      if (this % i == 0) {
        factors.add(i);
      }
    }
    return factors;
  }

  /// 获取质因子
  List<int> get primeFactors {
    final factors = <int>[];
    int n = this;
    int divisor = 2;

    while (n > 1) {
      while (n % divisor == 0) {
        factors.add(divisor);
        n ~/= divisor;
      }
      divisor++;
    }

    return factors;
  }

  /// 获取最大公约数
  int gcd(int other) {
    int a = abs();
    int b = other.abs();

    while (b != 0) {
      final temp = b;
      b = a % b;
      a = temp;
    }

    return a;
  }

  // /// 获取最小公倍数
  // int lcm(int other) {
  //   return (this * other).abs ~/ gcd(other);
  // }

  /// 转换为罗马数字
  String get toRoman {
    if (this <= 0 || this > 3999) {
      throw ArgumentError('Roman numerals are only defined for 1-3999');
    }

    const romanNumerals = {
      1000: 'M',
      900: 'CM',
      500: 'D',
      400: 'CD',
      100: 'C',
      90: 'XC',
      50: 'L',
      40: 'XL',
      10: 'X',
      9: 'IX',
      5: 'V',
      4: 'IV',
      1: 'I',
    };

    String result = '';
    int remaining = this;

    for (final entry in romanNumerals.entries) {
      while (remaining >= entry.key) {
        result += entry.value;
        remaining -= entry.key;
      }
    }

    return result;
  }

  /// 格式化数字（添加千位分隔符）
  String get formatted {
    return toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match match) => '${match[1]},',
    );
  }

  /// 重复字符串
  String repeat(String str) {
    return str * this;
  }

  /// 创建列表
  List<T> times<T>(T Function(int index) generator) {
    return List.generate(this, generator);
  }

  /// 创建固定值列表
  List<T> timesValue<T>(T value) {
    return List.filled(this, value);
  }
}

/// int 的扩展方法，处理时间
extension IntTimeExtensions on int? {
  /// 将 Unix 时间戳（毫秒）格式化为智能时间字符串
  /// * 今天之内  → `HH:mm`
  /// * 同一年    → `MM-dd HH:mm`
  /// * 跨年份    → `yyyy-MM-dd HH:mm`
  String get formatMillisToSmartTime {
    return (this ?? 0).toDate.formatMillisToSmartTime();
  }

  /// 将秒数转换为 MM:SS 或 HH:MM:SS 格式
  /// 当前int值表示秒数
  String get formatSecondsToSmartTime {
    var value = this ?? 0;
    final hours = value ~/ 3600;
    final minutes = (value % 3600) ~/ 60;
    final seconds = value % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  /// 将秒数转换为 HH:MM:SS 格式
  /// 当前int值表示秒数
  String get formatSecondsToHms {
    Duration duration = Duration(seconds: this ?? 0);
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    String twoDigitMilliseconds = twoDigits(
      (duration.inMilliseconds / 10).floor(),
    );
    return "$twoDigitMinutes:$twoDigitSeconds:$twoDigitMilliseconds";
  }

  /// 将秒数转换为 HH:MM:SS 格式
  /// 当前int值表示秒数
  /// 和[formatSecondsToHms]实现方式不一样
  String get formatSecondsToHms2 {
    return _formatDurationToHms(Duration(seconds: this ?? 0));
  }

  /// 将毫秒数转换为 HH:MM:SS 格式
  /// 当前int值表示毫秒数
  String get formatMillisToHms {
    return _formatDurationToHms(Duration(milliseconds: this ?? 0));
  }

  /// 将秒数格式化为友好阅读形式
  /// 当前int值表示秒数
  /// - 示例：`2h23m12s`
  /// - 示例：`23m12s`
  /// - 示例：`20s`
  String get formatSecondsToCompact {
    var value = this ?? 0;
    if (value <= 0) {
      return '0s';
    }
    int hours = value ~/ 3600;
    int minutes = (value % 3600) ~/ 60;
    int remainingSeconds = value % 60;
    if (hours > 0) {
      return "${hours}h${minutes}m${remainingSeconds}s";
    } else if (minutes > 0) {
      return "${minutes}m${remainingSeconds}s";
    }
    return "${remainingSeconds}s";
  }

  /// 判断当前时间戳（毫秒）与 [other] 的差值是否 ≤ [minutes] 分钟。
  ///
  /// - [minutes] 默认为 5；支持传入任意正整数。
  /// - 会取绝对值，因此不关心先后顺序。
  bool isWithinMinutes(int other, {int minutes = 5}) {
    if (minutes < 0) {
      throw ArgumentError.value(
        minutes,
        'minutes',
        'minutes must be a positive integer',
      );
    }
    final thisTime = DateTime.fromMillisecondsSinceEpoch(this ?? 0);
    final otherTime = DateTime.fromMillisecondsSinceEpoch(other);

    final diffInMinutes = thisTime.difference(otherTime).inMinutes.abs();

    return diffInMinutes <= minutes;
  }

  /// 将 Duration 转换为 HH:MM:SS 格式
  String _formatDurationToHms(Duration duration) {
    return DateFormat('HH:mm:ss', "en_US").format(
      DateTime(
        0,
        0,
        0,
        duration.inHours,
        duration.inMinutes.remainder(60),
        duration.inSeconds.remainder(60),
      ),
    );
  }

  /// 将时间戳转为 DateTime 对象
  DateTime get toDate {
    if ((this ?? 0) <= 0) return DateTime.now(); // 默认返回当前时间
    if (toString().length == 10) {
      // 假设是10位，即秒级时间戳，转为毫秒
      return DateTime.fromMillisecondsSinceEpoch((this! * 1000));
    } else {
      // 默认认为是毫秒级时间戳
      return DateTime.fromMillisecondsSinceEpoch(this!);
    }
  }
}

/// double 相关扩展方法
extension DoubleExtensions on double {
  /// 检查是否为整数
  bool get isInteger => this == roundToDouble();

  /// 四舍五入到指定小数位
  double roundTo(int decimals) {
    final factor = pow(10, decimals);
    return (this * factor).round() / factor;
  }

  /// 向上取整到指定小数位
  double ceilTo(int decimals) {
    final factor = pow(10, decimals);
    return (this * factor).ceil() / factor;
  }

  /// 向下取整到指定小数位
  double floorTo(int decimals) {
    final factor = pow(10, decimals);
    return (this * factor).floor() / factor;
  }

  /// 转换为百分比字符串
  String toPercentage([int decimals = 1]) {
    return '${(this * 100).roundTo(decimals)}%';
  }

  /// 获取平方
  double get squared => this * this;

  /// 获取立方
  double get cubed => this * this * this;

  /// 转换为角度
  double get toDegrees => this * 180 / pi;

  /// 转换为弧度
  double get toRadians => this * pi / 180;
}

extension PriceFormatting on double {
  /// 转换为货币字符串
  String toCurrency([String symbol = '\$', int decimals = 2]) {
    return '$symbol${roundTo(decimals).toStringAsFixed(decimals)}';
  }

  /// 正则表达式去除末尾的 .0（简单场景，无四舍五入）
  String toPriceStringSimple() {
    return toString().replaceAll(RegExp(r'\.0+$'), '');
  }

  /// NumberFormat 格式化，（推荐）
  /// 支持：
  ///  - 四舍五入
  ///  - 国际化
  ///  - 科学计数法自动处理
  String toPriceString() {
    // 普通数值格式：智能去除末尾 .0（如 6.00 → "6"，6.2 → "6.2"）
    return NumberFormat('#,##0.##').format(this);
  }
}

/// num 相关扩展方法
extension NumExtensions on num {
  /// 检查是否为正数
  bool get isPositive => this > 0;

  /// 检查是否为负数
  bool get isNegative => this < 0;

  /// 检查是否为零
  bool get isZero => this == 0 || this == 0.0;

  /// 检查是否在指定范围内
  bool isInRange(num min, num max) => this >= min && this <= max;

  /// 检查是否在指定范围内（不包含边界）
  bool isInRangeExclusive(num min, num max) => this > min && this < max;

  /// 线性插值
  num lerp(num other, double t) => this + (other - this) * t;

  /// 获取最大值
  num max(num other) => this > other ? this : other;

  /// 获取最小值
  num min(num other) => this < other ? this : other;

  /// 检查是否为偶数
  bool get isEven => this % 2 == 0;

  /// 检查是否为奇数
  bool get isOdd => this % 2 != 0;

  /// 格式化数字（添加千位分隔符）
  String get formatted {
    return toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match match) => '${match[1]},',
    );
  }
}
