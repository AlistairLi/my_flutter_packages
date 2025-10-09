import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:inapp_purchase_wrapper/inapp_purchase_wrapper.dart';
import 'package:inapp_purchase_wrapper/src/platform/i_inapp_platform.dart';

class InAppIOSPlatform implements IInAppPlatform {
  @override
  PurchaseParam createPurchaseParam(
      {required ProductDetails productDetails,
      required String applicationUserName}) {
    return AppStorePurchaseParam(
      productDetails: productDetails,
      applicationUserName: applicationUserName,
    );
  }

  @override
  Future<VerifyResult> verifyPurchase(
      {required IInAppStorage storage,
      required PurchaseDetails purchaseDetails,
      required IInAppVerifier verifier}) async {
    // TODO 注意，iOS在补单时（调用InAppPurchase.instance.restorePurchases()），不能通过透传从details 拿到orderNo，需要另外处理
    // TODO 通过 details.verificationData.localVerificationData来获取试试。
    var details = purchaseDetails as AppStorePurchaseDetails;
    var orderNo = details.skPaymentTransaction.payment.applicationUsername;
    if (orderNo == null || orderNo.isEmpty) {
      return VerifyResult.invalid(
          errorMsg: "orderNo is empty, because applicationUsername on Iap.");
    }
    var orderData = await storage.getOrderData(orderNo);

    var orderModel = AppStoreOrderModel.fromJson(orderData ?? {});
    if (orderData == null || orderData.isEmpty) {
      orderModel.orderNo = orderNo;
    }
    orderModel.purchaseID = details.purchaseID;
    orderModel.serverVerificationData =
        details.verificationData.serverVerificationData;

    await storage.updateOrderData(orderNo, orderModel.toJson());

    return verifier.verify(orderModel);
  }
}
