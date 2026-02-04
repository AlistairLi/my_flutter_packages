import 'package:inapp_purchase_wrapper/inapp_purchase_wrapper.dart';

/// 普通商品验单
abstract class IInAppVerifier {
  Future<VerifyResult> verify(IapOrderModel data);

  bool shouldRetry(VerifyResult result) {
    return !result.isValid;
  }
}
