import 'package:inapp_purchase_wrapper/inapp_purchase_wrapper.dart';
import 'package:inapp_purchase_wrapper/src/platform/i_inapp_platform.dart';

class InAppAndroidPlatform implements IInAppPlatform {
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
