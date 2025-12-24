import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:inapp_purchase_wrapper/inapp_purchase_wrapper.dart';
import 'package:inapp_purchase_wrapper/src/platform/i_inapp_platform.dart';

class InAppAndroidPlatform extends IInAppPlatform {
  @override
  PurchaseParam createPurchaseParam(
      {required ProductDetails productDetails,
      required String applicationUserName}) {
    return GooglePlayPurchaseParam(
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
    var details = purchaseDetails as GooglePlayPurchaseDetails;
    Map<String, dynamic>? orderData;
    var orderNo = details.billingClientPurchase.obfuscatedAccountId;
    var purchaseID = details.purchaseID;
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
    orderModel.purchaseID = details.purchaseID;
    orderModel.originalJson = details.billingClientPurchase.originalJson;
    orderModel.signature = details.billingClientPurchase.signature;
    return orderModel;
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

    return verifier.verify(orderModel);
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
              'consumePurchase failed with responseCode: ${resultWrapper.responseCode} on GP.',
        );
      }
    }
    if (purchaseDetails.pendingCompletePurchase) {
      await inAppPurchase.completePurchase(purchaseDetails);
    }
  }
}
