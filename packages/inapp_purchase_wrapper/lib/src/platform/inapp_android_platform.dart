import 'package:in_app_purchase_android/in_app_purchase_android.dart';
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
    var orderNo = details.billingClientPurchase.obfuscatedAccountId;
    if (orderNo == null || orderNo.isEmpty) {
      return VerifyResult.invalid(
          errorMsg:
              "orderNo is empty, because obfuscatedAccountId is empty on GP.");
    }

    var orderData = await storage.getOrderData(orderNo);

    var orderModel = GooglePlayOrderModel.fromJson(orderData ?? {});
    if (orderData == null || orderData.isEmpty) {
      orderModel.orderNo = orderNo;
    }
    orderModel.purchaseID = details.purchaseID;
    orderModel.originalJson = details.billingClientPurchase.originalJson;
    orderModel.signature = details.billingClientPurchase.signature;

    await storage.updateOrderData(orderNo, orderModel.toJson());

    return verifier.verify(orderModel);
  }
}
