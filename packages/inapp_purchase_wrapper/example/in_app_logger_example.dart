import 'package:inapp_purchase_wrapper/inapp_purchase_wrapper.dart';

class IAPLoggerExample extends IIAPLogger {
  @override
  void log(String event,
      {String? productId,
      String? orderNo,
      String? errorCode,
      String? errorMsg}) {
    // 上报到项目的服务器
  }
}
