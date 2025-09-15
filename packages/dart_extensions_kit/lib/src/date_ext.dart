import 'package:intl/intl.dart';

/// DateTime 的扩展方法
/// see [DateUtils]
extension DateTimeExtensions on DateTime {
  /// 获取星期几
  String getWeekdayName({String? newPattern, String? locale}) =>
      DateFormat(newPattern ?? 'EEEE', locale ?? Intl.getCurrentLocale())
          .format(this);

  /// 获取星期几（缩写）
  String getWeekdayNameShort({String? locale}) =>
      getWeekdayName(newPattern: 'EEE', locale: locale);

  /// 英文（美国）
  String get weekdayEn => getWeekdayName(locale: 'en_US'); // Monday
  String get weekdayShortEn => getWeekdayNameShort(locale: 'en_US'); // Mon

  /// 中文（简体）
  String get weekdayCn => getWeekdayName(locale: 'zh_CN'); // 星期一
  String get weekdayShortCn => getWeekdayNameShort(locale: 'zh_CN');

  /// 获取月份名称
  String getMonthName({String? newPattern, String? locale}) =>
      DateFormat(newPattern ?? 'MMMM', locale ?? Intl.getCurrentLocale())
          .format(this);

  /// 获月份名称（缩写）
  String getMonthNameShort({String? locale}) =>
      getMonthName(newPattern: "MMM", locale: locale);

  /// 获取月份名称（英文）
  String get monthEn => getMonthName(locale: "en_US");

  String get monthShortEn => getMonthNameShort(locale: "en_US");

  /// 检查是否为今天
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// 检查是否为昨天
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  /// 检查是否为明天
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year &&
        month == tomorrow.month &&
        day == tomorrow.day;
  }

  /// 检查是否为本周
  bool get isThisWeek {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
        isBefore(endOfWeek.add(const Duration(days: 1)));
  }

  /// 检查是否为本月
  bool get isThisMonth {
    final now = DateTime.now();
    return year == now.year && month == now.month;
  }

  /// 检查是否为本年
  bool get isThisYear {
    return year == DateTime.now().year;
  }

  /// 获取月初
  DateTime get startOfMonth => DateTime(year, month, 1);

  /// 获取月末
  DateTime get endOfMonth => DateTime(year, month + 1, 0);

  /// 获取年初
  DateTime get startOfYear => DateTime(year, 1, 1);

  /// 获取年末
  DateTime get endOfYear => DateTime(year, 12, 31);

  /// 获取本周开始（星期一）
  DateTime get startOfWeek {
    final daysFromMonday = weekday - 1;
    return subtract(Duration(days: daysFromMonday));
  }

  /// 获取本周结束（星期日）
  DateTime get endOfWeek {
    final daysToSunday = 7 - weekday;
    return add(Duration(days: daysToSunday));
  }

  /// 格式化日期（yyyy-MM-dd）
  String get formatDate =>
      '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';

  /// 格式化时间（HH:mm:ss）
  String get formatTime =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:${second.toString().padLeft(2, '0')}';

  /// 格式化日期时间（yyyy-MM-dd HH:mm:ss）
  String get formatDateTime => '$formatDate $formatTime';

  /// 格式化日期时间（yyyy-MM-dd HH:mm）
  String get formatDateTimeShort =>
      '$formatDate ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  /// 格式化日期时间
  String formatMillisToSmartTime([String? locale]) {
    //同一天
    if (isToday) {
      return DateFormat('HH:mm', locale ?? "en_US").format(this);
    }
    //同一年
    if (isThisYear) {
      return DateFormat('MM-dd HH:mm', locale ?? "en_US").format(this);
    }
    return DateFormat('yyyy-MM-dd HH:mm', locale ?? "en_US").format(this);
  }

  /// 相对时间描述
  String get relativeTime {
    final now = DateTime.now();
    final difference = now.difference(this);

    // 处理未来时间
    if (difference.isNegative) {
      final absDifference = difference.abs();
      if (absDifference.inDays > 365) {
        return '${(absDifference.inDays / 365).floor()} years later';
      } else if (absDifference.inDays > 30) {
        return '${(absDifference.inDays / 30).floor()} months later';
      } else if (absDifference.inDays > 0) {
        return '${absDifference.inDays} d later';
      } else if (absDifference.inHours > 0) {
        return '${absDifference.inHours} h later';
      } else if (absDifference.inMinutes > 0) {
        return '${absDifference.inMinutes} m later';
      } else {
        return 'soon';
      }
    }

    // 处理过去时间
    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} years ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} m ago';
    } else {
      return 'just now';
    }
  }

  /// 获取年龄
  int get age {
    final now = DateTime.now();
    int age = now.year - year;
    if (now.month < month || (now.month == month && now.day < day)) {
      age--;
    }
    return age;
  }

  /// 添加年
  DateTime addYears(int years) => DateTime(
      year + years, month, day, hour, minute, second, millisecond, microsecond);

  /// 添加月
  DateTime addMonths(int months) {
    final newYear = year + ((month + months - 1) ~/ 12);
    final newMonth = ((month + months - 1) % 12) + 1;
    return DateTime(
        newYear, newMonth, day, hour, minute, second, millisecond, microsecond);
  }

  /// 添加天
  DateTime addDays(int days) => add(Duration(days: days));

  /// 添加小时
  DateTime addHours(int hours) => add(Duration(hours: hours));

  /// 添加分钟
  DateTime addMinutes(int minutes) => add(Duration(minutes: minutes));

  /// 添加秒
  DateTime addSeconds(int seconds) => add(Duration(seconds: seconds));

  /// 减去年
  DateTime subtractYears(int years) => DateTime(
      year - years, month, day, hour, minute, second, millisecond, microsecond);

  /// 减去月
  DateTime subtractMonths(int months) => addMonths(-months);

  /// 减去天
  DateTime subtractDays(int days) => subtract(Duration(days: days));

  /// 减去小时
  DateTime subtractHours(int hours) => subtract(Duration(hours: hours));

  /// 减去分钟
  DateTime subtractMinutes(int minutes) => subtract(Duration(minutes: minutes));

  /// 减去秒
  DateTime subtractSeconds(int seconds) => subtract(Duration(seconds: seconds));

  /// 设置时间
  DateTime setTime(
      {int? hour,
      int? minute,
      int? second,
      int? millisecond,
      int? microsecond}) {
    return DateTime(
      year,
      month,
      day,
      hour ?? this.hour,
      minute ?? this.minute,
      second ?? this.second,
      millisecond ?? this.millisecond,
      microsecond ?? this.microsecond,
    );
  }

  /// 设置日期
  DateTime setDate({int? year, int? month, int? day}) {
    return DateTime(
      year ?? this.year,
      month ?? this.month,
      day ?? this.day,
      hour,
      minute,
      second,
      millisecond,
      microsecond,
    );
  }

  /// 检查是否为工作日
  bool get isWorkday => weekday >= 1 && weekday <= 5;

  /// 检查是否为周末
  bool get isWeekend => weekday == 6 || weekday == 7;

  /// 获取季度
  int get quarter => ((month - 1) ~/ 3) + 1;

  /// 获取季度开始日期
  DateTime get startOfQuarter {
    final quarterMonth = ((quarter - 1) * 3) + 1;
    return DateTime(year, quarterMonth, 1);
  }

  /// 获取季度结束日期
  DateTime get endOfQuarter {
    final quarterMonth = quarter * 3;
    return DateTime(year, quarterMonth + 1, 0);
  }
}
