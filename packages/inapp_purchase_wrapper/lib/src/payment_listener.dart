import 'package:inapp_purchase_wrapper/inapp_purchase_wrapper.dart';

/// 支付监听
abstract class PaymentListener {
  /// 等待中
  ///
  /// [purchaseDetails] - 购买详情，包含购买相关信息
  /// [message] - 提示文案，用于显示给用户的toast消息，如果为空可使用默认提示
  void onPending(PurchaseDetails purchaseDetails, String? message);

  /// 支付成功
  void onSuccess(IapOrderModel order);

  /// 支付取消
  ///
  /// [purchaseDetails] - 购买详情，包含购买相关信息
  /// [message] - 提示文案，用于显示给用户的toast消息，如果为空可使用默认提示
  void onCanceled(PurchaseDetails purchaseDetails, String? message);

  /// 支付错误
  ///
  /// [error] - 错误信息
  /// [message] - 提示文案，用于显示给用户的toast消息，如果为空可使用默认提示
  void onError(IAPError error, String? message);

  /// 购买列表为空
  void onPurchaseDetailsEmpty();
}
