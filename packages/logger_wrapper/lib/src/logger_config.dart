import 'package:logger_wrapper/src/logger_level.dart';

class LoggerConfig {
  LoggerConfig._();

  static final LoggerConfig _instance = LoggerConfig._();

  static LoggerConfig get instance => _instance;

  /// 是否启用日志打印
  bool enable = true;

  /// 是否将日志写入文件（用于 debug）
  bool writeToFile = false;

  /// 最低日志级别（低于此级别的日志不打印）
  LoggerLevel minLogLevel = LoggerLevel.debug;
}
