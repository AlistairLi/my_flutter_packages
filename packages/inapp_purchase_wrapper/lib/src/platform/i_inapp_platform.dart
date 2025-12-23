import 'package:inapp_purchase_wrapper/inapp_purchase_wrapper.dart';

abstract class IInAppPlatform {
  PurchaseParam createPurchaseParam({
    required ProductDetails productDetails,
    required String applicationUserName,
  });

  String getProductDetailsInfo(ProductDetails productDetails);

  Future<VerifyResult> verifyPurchase({
    required IInAppStorage storage,
    required PurchaseDetails purchaseDetails,
    required IInAppVerifier verifier,
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
}
