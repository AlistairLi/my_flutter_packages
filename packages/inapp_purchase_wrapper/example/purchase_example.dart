import 'dart:io';

import 'package:inapp_purchase_wrapper/inapp_purchase_wrapper.dart';

import 'in_app_android_verifier_example.dart';
import 'in_app_ios_verifier_example.dart';
import 'in_app_listener_example.dart';
import 'in_app_logger_example.dart';
import 'in_app_storage_example.dart';

void main() {
  InAppManager inAppManager = InAppManager(
    paymentListener: InAppPurchaseListenerExample(),
    inAppVerifier: Platform.isAndroid
        ? InAppAndroidVerifierExample()
        : InAppIosVerifierExample(),
    inAppStorage: InAppStorageImplExample(),
    logger: IAPLoggerExample(),
  );

  // 登录后启动监听
  inAppManager.init();

  // 登录后启动恢复购买（补单）
  inAppManager.startRestorePurchases();

  // 购买
  inAppManager.startPurchase("product_id_xxx", "order_no_xxx");

}
