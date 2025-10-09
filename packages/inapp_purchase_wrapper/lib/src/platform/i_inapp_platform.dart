import 'package:inapp_purchase_wrapper/inapp_purchase_wrapper.dart';

abstract class IInAppPlatform {
  PurchaseParam createPurchaseParam({
    required ProductDetails productDetails,
    required String applicationUserName,
  });

  Future<VerifyResult> verifyPurchase({
    required IInAppStorage storage,
    required PurchaseDetails purchaseDetails,
    required IInAppVerifier verifier,
  });
}
