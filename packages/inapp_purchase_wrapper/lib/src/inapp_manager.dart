import 'dart:async';
import 'dart:io';

import 'package:inapp_purchase_wrapper/inapp_purchase_wrapper.dart';
import 'package:inapp_purchase_wrapper/src/platform/i_inapp_platform.dart';

/// 内购工具类
///
/// 一个通用的内购管理工具，用于处理iOS和Android平台的应用内购买流程
/// 提供了初始化、购买、恢复购买、查询历史订单等功能
class InAppManager {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;

  /// 内购事件流监听
  StreamSubscription? _purchaseSubscription;

  // 在 iOS 上必须启用自动消耗（auto-consume）。
  // To try without auto-consume on another platform, change `true` to `false` here.
  // ignore: no_literal_bool_comparisons
  final bool _kAutoConsume = Platform.isIOS || true;

  final IInAppPlatform _inAppPlatform;

  /// 内购监听回调
  final PaymentListener _paymentListener;

  /// 商品验单
  final IInAppVerifier _inAppVerifier;

  final IInAppStorage _inAppStorage;

  /// 日志回调
  final IIAPLogger? _logger;

  InAppManager({
    required PaymentListener paymentListener,
    required IInAppVerifier inAppVerifier,
    required IInAppStorage inAppStorage,
    IIAPLogger? logger,
  })  : _inAppPlatform =
            Platform.isAndroid ? InAppAndroidPlatform() : InAppIOSPlatform(),
        _paymentListener = paymentListener,
        _inAppStorage = inAppStorage,
        _inAppVerifier = inAppVerifier,
        _logger = logger;

  /// 开始监听内购
  void startListening() {
    if (_purchaseSubscription != null) {
      _purchaseSubscription?.cancel();
    }
    final Stream purchaseUpdated = _inAppPurchase.purchaseStream;
    _purchaseSubscription = purchaseUpdated.listen((purchaseDetails) {
      _handlePurchaseUpdate(purchaseDetails);
    }, onDone: () {
      _log(
        'purchase_listen_onDone',
        errorMsg: 'Internal purchase monitoring complete',
      );
    }, onError: (error) {
      _log(
        'purchase_listen_onError',
        errorMsg: error.toString(),
      );
    });
  }

  /// 停止监听内购
  void stopListening() {
    _purchaseSubscription?.cancel();
    _purchaseSubscription = null;
  }

  /// 启动补单，登录成功进入首页后调用，延迟500毫秒调用。
  void startRestorePurchases() {
    Future.delayed(Duration(milliseconds: 500)).then((value) {
      _restorePurchases();
    });
  }

  /// 启动购买
  ///
  /// [productId] 产品 code
  /// [orderNo] 订单号
  /// [isConsumable] 是否消耗型商品，订阅属于非消耗型商品
  Future<bool> startPurchase(String? productId, String? orderNo) async {
    if (productId == null || productId.isEmpty) {
      _onError(
        orderNo: orderNo,
        source: "checkProductId",
        errorMsg: "productId is empty",
      );
      return false;
    }
    if (orderNo == null || orderNo.isEmpty) {
      _onError(
        productId: productId,
        source: "checkOrderNo",
        errorMsg: "orderNo is empty",
      );
      return false;
    }

    // 检查服务是否可用
    final bool available = await _inAppPurchase.isAvailable();
    if (!available) {
      _onError(
        productId: productId,
        orderNo: orderNo,
        source: "checkIsAvailable",
        errorMsg: "available is $available",
      );
      return false;
    }

    // 查询产品信息
    final ProductDetailsResponse response =
        await _inAppPurchase.queryProductDetails({productId});

    if (response.notFoundIDs.isNotEmpty) {
      _onError(
        productId: productId,
        orderNo: orderNo,
        source: "notFoundIDs",
        errorMsg: "notFoundIDs",
      );
      return false;
    }

    // 获取产品列表
    final List<ProductDetails> products = response.productDetails;
    if (products.isEmpty) {
      _onError(
        productId: productId,
        orderNo: orderNo,
        source: "checkProductDetails",
        errorMsg: "ProductDetailsResponse.productDetails is empty",
      );
      return false;
    }
    var productDetails = products.first;

    // 开始购买
    try {
      var purchaseParam = _inAppPlatform.createPurchaseParam(
        productDetails: productDetails,
        applicationUserName: orderNo,
      );

      bool result = await _inAppPurchase.buyConsumable(
        purchaseParam: purchaseParam,
        autoConsume: _kAutoConsume,
      );

      IapOrderModel order = IapOrderModel(
        orderNo: orderNo,
        purchaseID: "",
        productId: productDetails.id,
        price: productDetails.price,
        rawPrice: productDetails.rawPrice,
        currencyCode: productDetails.currencyCode,
        currencySymbol: productDetails.currencySymbol,
      );
      _inAppStorage.saveOrderData(orderNo, order.toJson());

      _log(
        'buyConsumable_result',
        productId: productId,
        orderNo: orderNo,
        errorMsg: "$result",
      );
      return result;
    } catch (e) {
      _onError(
        productId: productId,
        orderNo: orderNo,
        source: "buyConsumable_catch",
        errorMsg: "error: ${e.toString()}",
      );
      return false;
    }
  }

  /// 处理购买更新
  /// 注意：调用InAppPurchase.instance.restorePurchases()后，如果没有需要补单，purchaseDetailsList为空
  /// TODO 注意：iOS 在重启后调用 await InAppPurchase.instance.restorePurchases()，才能获取到补单数据；退出登录时获取不到，需要另外处理！
  void _handlePurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    for (var purchaseDetails in purchaseDetailsList) {
      _processPurchaseDetails(purchaseDetails);
    }
  }

  /// 处理单个购买详情
  void _processPurchaseDetails(PurchaseDetails purchaseDetails) async {
    if (purchaseDetails.status == PurchaseStatus.pending) {
      // 等待中
      _paymentListener.onPending(purchaseDetails);
    } else {
      if (purchaseDetails.status == PurchaseStatus.error) {
        // 错误
        var iapError = purchaseDetails.error;
        _onError(
          productId: purchaseDetails.productID,
          source: iapError?.source ?? "",
          errorCode: iapError?.code,
          errorMsg: iapError?.message,
          details: purchaseDetails,
        );
      } else if (purchaseDetails.status == PurchaseStatus.canceled) {
        // 取消
        _onCanceled(purchaseDetails);
      } else if (purchaseDetails.status == PurchaseStatus.purchased ||
          purchaseDetails.status == PurchaseStatus.restored) {
        var result = await _verifyPurchase(purchaseDetails);
        if (result.isValid) {
          _deliverProduct(result.orderModel);
        } else {
          _handleInvalidPurchase(purchaseDetails, result);
        }
      }
      if (purchaseDetails.pendingCompletePurchase) {
        _completePurchase(purchaseDetails);
      }
    }
  }

  Future<VerifyResult> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    VerifyResult verifyResult;
    try {
      verifyResult = await _inAppPlatform.verifyPurchase(
        storage: _inAppStorage,
        purchaseDetails: purchaseDetails,
        verifier: _inAppVerifier,
      );
    } catch (e) {
      verifyResult = VerifyResult(
        isValid: false,
        errorCode: "-1",
        errorMsg: e.toString(),
        orderModel: IapOrderModel(),
      );
    }
    return verifyResult;
  }

  void _deliverProduct(IapOrderModel orderModel) {
    try {
      _inAppStorage.removeOrder(orderModel.orderNo);
    } catch (e) {
      _log(
        'remove_order_catch',
        productId: orderModel.productId,
        orderNo: orderModel.orderNo,
        errorCode: "-1",
        errorMsg: e.toString(),
      );
    }

    try {
      _onSuccess(orderModel);
    } catch (e) {
      _log(
        'on_success_catch',
        productId: orderModel.productId,
        orderNo: orderModel.orderNo,
        errorCode: "-1",
        errorMsg: e.toString(),
      );
    }
  }

  void _handleInvalidPurchase(
      PurchaseDetails purchaseDetails, VerifyResult result) {
    _onError(
      source: "verifyPurchaseFailed",
      productId: purchaseDetails.productID,
      orderNo: result.orderModel.orderNo,
      errorCode: result.errorCode,
      errorMsg: result.errorMsg,
      details: purchaseDetails,
    );
  }

  /// 完成购买
  Future<bool> _completePurchase(PurchaseDetails purchaseDetails) async {
    try {
      await _inAppPurchase.completePurchase(purchaseDetails);
      return true;
    } catch (e) {
      _log(
        'completePurchase_catch',
        productId: purchaseDetails.productID,
        errorCode: "-1",
        errorMsg: e.toString(),
      );
    }
    return false;
  }

  /// 查询并补单
  void _restorePurchases() {
    try {
      _inAppPurchase.restorePurchases();
    } catch (e) {
      _log('restorePurchases_catch', errorMsg: e.toString());
    }
  }

  void _onError(
      {required String source,
      String? productId,
      String? orderNo,
      String? errorCode,
      String? errorMsg,
      dynamic details}) {
    _log(
      "onError_$source",
      productId: productId,
      orderNo: orderNo,
      errorCode: errorCode,
      errorMsg: errorMsg,
    );
    _paymentListener.onError(
      IAPError(
        source: source,
        code: errorCode ?? '',
        message: errorMsg ?? '',
        details: details,
      ),
    );
  }

  void _onCanceled(PurchaseDetails purchaseDetails) {
    _log(
      'onCanceled_${purchaseDetails.error?.source ?? ''}',
      productId: purchaseDetails.productID,
      errorCode: purchaseDetails.error?.code ?? "",
      errorMsg:
          "message: ${purchaseDetails.error?.message ?? ""}, details: ${purchaseDetails.error?.details.toString()}",
    );
    _paymentListener.onCanceled(purchaseDetails);
  }

  void _onSuccess(IapOrderModel data) {
    _paymentListener.onSuccess(data);
  }

  /// 记录日志
  void _log(
    String event, {
    String? productId,
    String? orderNo,
    String? errorCode,
    String? errorMsg,
  }) {
    _logger?.log(event,
        productId: productId,
        orderNo: orderNo,
        errorCode: errorCode,
        errorMsg: errorMsg);
  }
}
