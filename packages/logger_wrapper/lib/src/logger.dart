import 'package:logger/logger.dart';
import 'package:logger_wrapper/src/logger_config.dart';
import 'package:logger_wrapper/src/logger_level.dart';

/// 日志工具
class LoggerWrapper {
  LoggerWrapper._();

  static final Logger _logger = Logger(
    printer: PrefixPrinter(SimplePrinter()),
  );

  static void v(dynamic message) {
    _logger.t(message, stackTrace: StackTrace.current);
  }

  static void d(dynamic message) {
    _logger.d(message);
  }

  static void e(dynamic message) {
    _logger.e(message);
  }

  static void w(dynamic message) {
    _logger.w(message);
  }

  static void i(dynamic message) {
    _logger.i(message);
  }
}

void mLog(
  dynamic message, {
  String? tag,
  LoggerLevel level = LoggerLevel.debug,
}) {
  if (!LoggerConfig.instance.enable) {
    return;
  }
  if (level.index < LoggerConfig.instance.minLogLevel.index) {
    return;
  }

  if (tag != null && tag.isNotEmpty) {
    message = '[$tag]  $message';
  }
  switch (level) {
    case LoggerLevel.verbose:
      LoggerWrapper.v(message);
      break;
    case LoggerLevel.debug:
      LoggerWrapper.d(message);
      break;
    case LoggerLevel.info:
      LoggerWrapper.i(message);
      break;
    case LoggerLevel.warning:
      LoggerWrapper.w(message);
      break;
    case LoggerLevel.error:
      LoggerWrapper.e(message);
      break;
  }
}

void mLogV(dynamic message, {String? tag}) => mLog(
      message,
      tag: tag,
      level: LoggerLevel.verbose,
    );

void mLogI(dynamic message, {String? tag}) => mLog(
      message,
      tag: tag,
      level: LoggerLevel.info,
    );

void mLogW(dynamic message, {String? tag}) => mLog(
      message,
      tag: tag,
      level: LoggerLevel.warning,
    );

void mLogE(dynamic message, {String? tag}) => mLog(
      message,
      tag: tag,
      level: LoggerLevel.error,
    );
