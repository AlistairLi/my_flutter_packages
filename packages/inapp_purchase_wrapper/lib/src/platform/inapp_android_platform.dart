import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:inapp_purchase_wrapper/inapp_purchase_wrapper.dart';
import 'package:inapp_purchase_wrapper/src/platform/i_inapp_platform.dart';

class InAppAndroidPlatform extends IInAppPlatform {
  @override
  PurchaseParam createPurchaseParam(
      {required ProductDetails productDetails,
      required String applicationUserName}) {
    return PurchaseParam(
      productDetails: productDetails,
      applicationUserName: applicationUserName,
    );
  }

  @override
  String getProductDetailsInfo(ProductDetails productDetails) {
    var buffer = getProductDetailsBuffer(productDetails);
    if (productDetails is GooglePlayProductDetails) {
      var detailsWrapper = productDetails.productDetails;
      buffer.write(', productType: ${detailsWrapper.productType.name}');
      buffer.write(', name: ${detailsWrapper.name}');
      var oneTimeDetails = detailsWrapper.oneTimePurchaseOfferDetails;
      if (oneTimeDetails != null) {
        buffer.write(
            ', OneTimePurchaseOfferDetailsWrapper{formattedPrice: ${oneTimeDetails.formattedPrice}');
        buffer
            .write(', priceAmountMicros: ${oneTimeDetails.priceAmountMicros}');
        buffer
            .write(', priceCurrencyCode: ${oneTimeDetails.priceCurrencyCode}}');
      }
    }
    return buffer.toString();
  }

  @override
  Future<IapOrderModel?> getOrderModel(
      {required IInAppStorage storage,
      required PurchaseDetails purchaseDetails}) async {
    var purchaseID = purchaseDetails.purchaseID;
    // 在 canceled等状态的订单，purchaseDetails 不是 GooglePlayPurchaseDetails
    if (purchaseDetails is GooglePlayPurchaseDetails) {
      Map<String, dynamic>? orderData;
      var orderNo = purchaseDetails.billingClientPurchase.obfuscatedAccountId;
      if (orderNo != null && orderNo.isNotEmpty) {
        orderData = await storage.getOrderData(orderNo);
      } else if (purchaseID != null && purchaseID.isNotEmpty) {
        orderData = await storage.getOrderDataFromPurId(purchaseID);
      } else {
        return null;
      }

      if ((orderData == null || orderData.isEmpty) &&
          (orderNo == null || orderNo.isEmpty)) {
        return null;
      }

      var orderModel = GooglePlayOrderModel.fromJson(orderData ?? {});
      if ((orderData == null || orderData.isEmpty) &&
          (orderNo != null && orderNo.isNotEmpty)) {
        orderModel.orderNo = orderNo;
      }
      orderModel.purchaseID = purchaseID;
      orderModel.originalJson =
          purchaseDetails.billingClientPurchase.originalJson;
      orderModel.signature = purchaseDetails.billingClientPurchase.signature;
      return orderModel;
    } else if (purchaseID != null && purchaseID.isNotEmpty) {
      Map<String, dynamic>? orderData =
          await storage.getOrderDataFromPurId(purchaseID);
      if (orderData == null || orderData.isEmpty) {
        return null;
      }
      var orderModel = GooglePlayOrderModel.fromJson(orderData);
      return orderModel;
    }
    return null;
  }

  @override
  Future<VerifyResult> verifyPurchase(
      {required IInAppStorage storage,
      required IapOrderModel? orderModel,
      required IInAppVerifier verifier}) async {
    if (orderModel == null) {
      return VerifyResult.invalid(
        errorMsg: "orderModel is null on verifyPurchase() on GP.",
      );
    }
    await storage.updateOrderData(orderModel.orderNo, orderModel.toJson());

    return verifyWithRetry(
      verifier: verifier,
      orderModel: orderModel,
    );
  }

  @override
  Future<void> completePurchase(
    InAppPurchase inAppPurchase,
    PurchaseDetails purchaseDetails, {
    bool? autoConsume,
    IIAPLogger? logger,
  }) async {
    if (autoConsume != true) {
      final InAppPurchaseAndroidPlatformAddition androidAddition = inAppPurchase
          .getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();
      var resultWrapper =
          await androidAddition.consumePurchase(purchaseDetails);
      if (resultWrapper.responseCode != BillingResponse.ok) {
        // 埋点上报
        logger?.log(
          'consume_order_failed',
          productId: purchaseDetails.productID,
          errorCode: resultWrapper.responseCode.name,
          errorMsg:
              'consumePurchase failed on GP, purchaseID: ${purchaseDetails.purchaseID}',
        );
      }
    }
    if (purchaseDetails.pendingCompletePurchase) {
      await inAppPurchase.completePurchase(purchaseDetails);
    }
  }

  @override
  String getUnavailableMessage() {
    return IAPToastMessages.androidNotAvailable;
  }
}
