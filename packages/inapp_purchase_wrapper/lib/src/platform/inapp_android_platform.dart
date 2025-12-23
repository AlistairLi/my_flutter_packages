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
  Future<VerifyResult> verifyPurchase(
      {required IInAppStorage storage,
      required PurchaseDetails purchaseDetails,
      required IInAppVerifier verifier}) async {
    var details = purchaseDetails as GooglePlayPurchaseDetails;
    Map<String, dynamic>? orderData;
    var orderNo = details.billingClientPurchase.obfuscatedAccountId;
    var purchaseID = details.purchaseID;
    if (orderNo != null && orderNo.isNotEmpty) {
      orderData = await storage.getOrderData(orderNo);
    } else if (purchaseID != null && purchaseID.isNotEmpty) {
      orderData = await storage.getOrderDataFromPurId(purchaseID);
    } else {
      return VerifyResult.invalid(
          errorMsg:
              "orderNo and purchaseID is empty on verifyPurchase() on GP.");
    }

    if ((orderData == null || orderData.isEmpty) &&
        (orderNo == null || orderNo.isEmpty)) {
      return VerifyResult.invalid(
          errorMsg:
              "orderData and orderNo is empty on verifyPurchase() on GP.");
    }

    var orderModel = GooglePlayOrderModel.fromJson(orderData ?? {});
    if ((orderData == null || orderData.isEmpty) &&
        (orderNo != null && orderNo.isNotEmpty)) {
      orderModel.orderNo = orderNo;
    }
    orderModel.purchaseID = details.purchaseID;
    orderModel.originalJson = details.billingClientPurchase.originalJson;
    orderModel.signature = details.billingClientPurchase.signature;

    await storage.updateOrderData(orderModel.orderNo, orderModel.toJson());

    return verifier.verify(orderModel);
  }
}
