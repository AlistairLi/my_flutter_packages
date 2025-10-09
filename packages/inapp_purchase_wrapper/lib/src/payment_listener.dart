import 'package:inapp_purchase_wrapper/inapp_purchase_wrapper.dart';

/// 支付监听
abstract class PaymentListener {
  /// 等待中
  void onPending(PurchaseDetails purchaseDetails);

  /// 支付成功
  void onSuccess(IapOrderModel order);

  /// 支付取消
  void onCanceled(PurchaseDetails purchaseDetails);

  /// 支付错误
  void onError(IAPError error);

  /// 购买列表为空
  void onPurchaseDetailsEmpty();
}
