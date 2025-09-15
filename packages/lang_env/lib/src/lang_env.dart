import 'package:flutter/widgets.dart';

class LangEnv {
  LangEnv._();

  /// 获取当前设备语言
  static Locale get deviceLocale =>
      WidgetsBinding.instance.platformDispatcher.locale;

  /// 获取当前设备语言列表
  static List<Locale> get deviceLocales =>
      WidgetsBinding.instance.platformDispatcher.locales;

  /// 获取当前设备语言代码
  static String get deviceLanguageCode => deviceLocale.languageCode;

  /// 获取当前设备国家代码
  static String get deviceCountryCode => deviceLocale.countryCode ?? "";

  /// 获取当前应用语言
  static Locale? getAppLanguageCode(BuildContext context) {
    return Localizations.maybeLocaleOf(context);
  }

  /// 设置语言环境值发生变化时的回调
  static void setOnLocaleChanged(VoidCallback? callback) {
    WidgetsBinding.instance.platformDispatcher.onLocaleChanged = callback;
  }
}
