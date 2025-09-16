import 'package:flutter_easyloading/flutter_easyloading.dart';

/// loading 初始化
class LoadingInitializer {
  LoadingInitializer._();

  static Future<void> initialize() async {
    EasyLoading.instance
      ..indicatorType = EasyLoadingIndicatorType.fadingCircle
      // ..indicatorType = EasyLoadingIndicatorType.ring
      ..loadingStyle = EasyLoadingStyle.dark
      ..maskType = EasyLoadingMaskType.clear;
  }
}
