abstract class IIAPNetworkStatusProvider {
  /// 返回当前网络状态（如 wifi/4g/5g/none 等）
  String? getNetworkStatus();
}
