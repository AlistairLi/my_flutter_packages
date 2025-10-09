import 'package:inapp_purchase_wrapper/inapp_purchase_wrapper.dart';

class InAppPurchaseListenerExample extends PaymentListener {
  @override
  void onPending(PurchaseDetails purchaseDetails) {}

  @override
  void onSuccess(IapOrderModel order) {
    // Loading.dismiss();
    // 发送充值成功事件
  }

  @override
  void onCanceled(PurchaseDetails purchaseDetails) {
    // Loading.dismiss();
  }

  @override
  void onError(IAPError error) {
    // Loading.dismiss();
  }

  @override
  void onPurchaseDetailsEmpty() {}
}
