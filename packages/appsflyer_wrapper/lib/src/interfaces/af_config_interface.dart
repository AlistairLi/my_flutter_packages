import 'package:appsflyer_wrapper/appsflyer_wrapper.dart';

abstract class AFConfigInterface {
  bool get isRelease;

  /// 获取 Appsflyer Key
  String get appsflyerAndroidKey;

  /// 获取 Appsflyer Key
  String get appsflyerIOSKey;

  /// 获取苹果 ID
  String get appleId;

  /// 判断是否应该上传归因数据
  Future<bool> shouldUploadAttributionData();

  /// 上报归因数据到服务器
  Future<bool> uploadAttributionData(AppsflyerArgs  data);
}
