import 'package:adjust_sdk/adjust_attribution.dart';

abstract class AJConfigInterface {
  bool get isRelease;

  /// 获取 Adjust App Token
  String get appToken;

  /// 获取购买事件 Token
  String get purchaseToken;

  /// 判断是否应该上传归因数据
  Future<bool> shouldUploadAttributionData();

  /// 上报归因数据到服务器
  Future<bool> uploadAttributionData(AdjustAttribution data);
}
