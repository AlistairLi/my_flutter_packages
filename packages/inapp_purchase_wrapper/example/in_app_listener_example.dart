import 'package:inapp_purchase_wrapper/inapp_purchase_wrapper.dart';

class InAppPurchaseListenerExample extends PaymentListener {
  @override
  void onPending(PurchaseDetails purchaseDetails, String? message) {
    // Loading.dismiss();
    if (message != null && message.isNotEmpty) {
      // 调用方可对message添加多语言支持
      // toast(message);
    } else {
      // toast("The purchase is pending, Please wait for the confirmation to be completed.");
    }
  }

  @override
  void onSuccess(IapOrderModel order) {
    // Loading.dismiss();
    // 发送充值成功事件
  }

  @override
  void onCanceled(PurchaseDetails purchaseDetails, String? message) {
    // Loading.dismiss();
    if (message != null && message.isNotEmpty) {
      // 调用方可对message添加多语言支持
      // toast(message);
    }
  }

  @override
  void onError(IAPError error, String? message) {
    // Loading.dismiss();
    if (message != null && message.isNotEmpty) {
      // 调用方可对message添加多语言支持
      // toast(message);
    }
  }

  @override
  void onPurchaseDetailsEmpty() {}
}
