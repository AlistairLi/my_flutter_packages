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
  Future<IapOrderModel?> getOrderModel(
      {required IInAppStorage storage,
      required PurchaseDetails purchaseDetails}) async {
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
      return null;
    }

    if ((orderData == null || orderData.isEmpty) &&
        (orderNo == null || orderNo.isEmpty)) {
      return null;
    }

    var orderModel = AppStoreOrderModel.fromJson(orderData ?? {});
    if ((orderData == null || orderData.isEmpty) &&
        (orderNo != null && orderNo.isNotEmpty)) {
      orderModel.orderNo = orderNo;
    }
    orderModel.purchaseID = details.purchaseID;
    orderModel.serverVerificationData =
        details.verificationData.serverVerificationData;
    return orderModel;
  }

  @override
  Future<VerifyResult> verifyPurchase(
      {required IInAppStorage storage,
      required IapOrderModel? orderModel,
      required IInAppVerifier verifier}) async {
    if (orderModel == null) {
      return VerifyResult.invalid(
        errorMsg: 'orderModel is null on verifyPurchase() on iOS.',
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
    if (purchaseDetails.pendingCompletePurchase) {
      await inAppPurchase.completePurchase(purchaseDetails);
    }
  }
}
