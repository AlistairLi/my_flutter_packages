import 'package:inapp_purchase_wrapper/inapp_purchase_wrapper.dart';

abstract class IInAppPlatform {
  int verifyRetryCount = 3;
  Duration verifyRetryDelay = const Duration(milliseconds: 5500);

  PurchaseParam createPurchaseParam({
    required ProductDetails productDetails,
    required String applicationUserName,
  });

  String getProductDetailsInfo(ProductDetails productDetails);

  Future<IapOrderModel?> getOrderModel({
    required IInAppStorage storage,
    required PurchaseDetails purchaseDetails,
  });

  Future<VerifyResult> verifyPurchase({
    required IInAppStorage storage,
    required IapOrderModel? orderModel,
    required IInAppVerifier verifier,
  });

  Future<VerifyResult> verifyWithRetry({
    required IInAppVerifier verifier,
    required IapOrderModel orderModel,
    int? retryCount,
    Duration? retryDelay,
  }) async {
    VerifyResult? lastResult;
    int remainingRetries = retryCount ?? verifyRetryCount;
    Duration delay = retryDelay ?? verifyRetryDelay;
    while (true) {
      if (lastResult != null && !verifier.shouldRetry(lastResult)) {
        return lastResult;
      }
      try {
        lastResult = await verifier.verify(orderModel);
      } catch (error) {
        lastResult = VerifyResult(
          isValid: false,
          orderModel: orderModel,
          errorMsg: error.toString(),
        );
      }
      if (lastResult.isValid == true) {
        return lastResult;
      }
      if (remainingRetries <= 0) {
        return lastResult;
      }
      await Future.delayed(delay);
      remainingRetries--;
    }
  }

  Future<void> completePurchase(
    InAppPurchase inAppPurchase,
    PurchaseDetails purchaseDetails, {
    bool? autoConsume,
    IIAPLogger? logger,
  });

  StringBuffer getProductDetailsBuffer(ProductDetails productDetails) {
    StringBuffer buffer = StringBuffer();
    buffer.write('productId: ${productDetails.id}');
    buffer.write(', title: ${productDetails.title}');
    buffer.write(', description: ${productDetails.description}');
    buffer.write(', price: ${productDetails.price}');
    buffer.write(', rawPrice: ${productDetails.rawPrice}');
    buffer.write(', currencyCode: ${productDetails.currencyCode}');
    buffer.write(', currencySymbol: ${productDetails.currencySymbol}');
    return buffer;
  }

  /// 获取 InAppPurchase 不可用时的提示语
  String getUnavailableMessage();
}
