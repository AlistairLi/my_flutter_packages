import 'package:inapp_purchase_wrapper/inapp_purchase_wrapper.dart';

class IAPNetworkStatusProviderExample extends IIAPNetworkStatusProvider {
  @override
  String? getNetworkStatus() {
    // 示例：由业务侧返回当前网络状态
    return 'wifi';
  }
}
