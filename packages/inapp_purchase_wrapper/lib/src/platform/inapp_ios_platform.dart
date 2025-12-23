import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:inapp_purchase_wrapper/inapp_purchase_wrapper.dart';
import 'package:inapp_purchase_wrapper/src/platform/i_inapp_platform.dart';

class InAppIOSPlatform extends IInAppPlatform {
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
  String getProductDetailsInfo(ProductDetails productDetails) {
    var buffer = getProductDetailsBuffer(productDetails);
    if (productDetails is AppStoreProductDetails) {
      var skProduct = productDetails.skProduct;
      buffer.write(', productIdentifier: ${skProduct.productIdentifier}');
      buffer.write(', localizedTitle: ${skProduct.localizedTitle}');
      buffer.write(', localizedDescription: ${skProduct.localizedDescription}');
      buffer.write(', price: ${skProduct.price}');
    }
    return buffer.toString();
  }

  @override
  Future<VerifyResult> verifyPurchase(
      {required IInAppStorage storage,
      required PurchaseDetails purchaseDetails,
      required IInAppVerifier verifier}) async {
    // 注意，iOS在补单时（调用InAppPurchase.instance.restorePurchases()），
    // 不能通过透传从details 拿到orderNo，需要通过purchaseID获取本地的订单信息。
    var details = purchaseDetails as AppStorePurchaseDetails;
    Map<String, dynamic>? orderData;
    var orderNo = details.skPaymentTransaction.payment.applicationUsername;
    var purchaseID = details.purchaseID;
    if (orderNo != null && orderNo.isNotEmpty) {
      orderData = await storage.getOrderData(orderNo);
    } else if (purchaseID != null && purchaseID.isNotEmpty) {
      orderData = await storage.getOrderDataFromPurId(purchaseID);
    } else {
      return VerifyResult.invalid(
          errorMsg:
              "orderNo and purchaseID is empty on verifyPurchase() on iOS.");
    }

    if ((orderData == null || orderData.isEmpty) &&
        (orderNo == null || orderNo.isEmpty)) {
      return VerifyResult.invalid(
          errorMsg:
              "orderData and orderNo is empty on verifyPurchase() on iOS.");
    }

    var orderModel = AppStoreOrderModel.fromJson(orderData ?? {});
    if ((orderData == null || orderData.isEmpty) &&
        (orderNo != null && orderNo.isNotEmpty)) {
      orderModel.orderNo = orderNo;
    }
    orderModel.purchaseID = details.purchaseID;
    orderModel.serverVerificationData =
        details.verificationData.serverVerificationData;

    await storage.updateOrderData(orderModel.orderNo, orderModel.toJson());

    return verifier.verify(orderModel);
  }
}
