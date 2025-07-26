/// 数据库日志
class UILogger {
  static bool enable = true;

  static void log(String tag, String message) {
    if (enable) {
      print('[app_ui]  ${tag.isNotEmpty ? '[$tag]  ' : ''}$message');
    }
  }
}

void uiLog(String msg, {String tag = ''}) {
  UILogger.log(tag, msg);
}
