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
  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;

  /// 商品详情缓存
  final Map<String, ProductDetails> _productDetailsCache = {};

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

  /// 初始化监听内购
  void init() {
    final Stream<List<PurchaseDetails>> purchaseUpdated =
        _inAppPurchase.purchaseStream;
    _purchaseSubscription = purchaseUpdated.listen((purchaseDetails) {
      _handlePurchaseUpdate(purchaseDetails);
    }, onDone: () {
      // _purchaseSubscription?.cancel();
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

  /// 启动补单，登录成功进入首页后调用
  void startRestorePurchases() {
    _restorePurchases();
  }

  /// 预加载商品详情
  void preloadProductDetails(List<String> productIds) async {
    List<ProductDetails> productDetailsList = await _loadProductDetails(
      productIds: productIds,
    );
    _putProductDetails(productDetailsList);
  }

  /// 清空商品详情缓存
  void clearProductDetailsCache() {
    _productDetailsCache.clear();
  }

  /// 向商店请求商品详情
  Future<List<ProductDetails>> _loadProductDetails({
    required List<String> productIds,
    String? orderNo,
    bool needCheckAvailable = true,
  }) async {
    if (needCheckAvailable) {
      final bool available = await _inAppPurchase.isAvailable();
      if (!available) {
        _onError(
          source: "isAvailable",
          productId: productIds.toString(),
          orderNo: orderNo,
          errorMsg: "available is $available, on loadProductDetails()",
        );
        return [];
      }
    }

    ProductDetailsResponse response =
        await _inAppPurchase.queryProductDetails(productIds.toSet());

    if (response.error != null) {
      _onError(
        source: "queryProductDetails",
        productId: productIds.toString(),
        orderNo: orderNo,
        errorMsg: response.error?.toString(),
      );
      return [];
    }

    if (response.productDetails.isEmpty) {
      _onError(
        source: "queryProductDetails",
        productId: productIds.toString(),
        orderNo: orderNo,
        errorMsg: "productDetails is empty",
      );
      return [];
    }
    return response.productDetails;
  }

  /// 将 List<ProductDetails> 缓存到 _productDetailsCache中
  void _putProductDetails(List<ProductDetails> productDetailsList) {
    for (var value in productDetailsList) {
      _productDetailsCache[value.id] = value;
    }
  }

  /// 获取单个商品详情
  ProductDetails? _getProductDetails(String productId) {
    return _productDetailsCache[productId];
  }

  /// 启动购买
  ///
  /// [productId] 商品 code
  /// [orderNo] 订单号
  Future<bool> startPurchase(String? productId, String? orderNo) async {
    if (productId == null || productId.isEmpty) {
      _onError(
        source: "checkProductId",
        productId: productId,
        orderNo: orderNo,
        errorMsg: "productId is empty",
      );
      return false;
    }
    if (orderNo == null || orderNo.isEmpty) {
      _onError(
        source: "checkOrderNo",
        productId: productId,
        orderNo: orderNo,
        errorMsg: "orderNo is empty",
      );
      return false;
    }

    // 检查服务是否可用
    final bool available = await _inAppPurchase.isAvailable();
    if (!available) {
      _onError(
        source: "isAvailable",
        productId: productId,
        orderNo: orderNo,
        errorMsg: "available is $available, on startPurchase()",
      );
      return false;
    }

    // 获取商品信息
    ProductDetails? productDetails = _getProductDetails(productId);

    // 如果商品信息为空，则从商店获取
    if (productDetails == null) {
      int retryCount = 3; // 设置最大重试次数
      while (retryCount >= 0) {
        var productDetailList = await _loadProductDetails(
          productIds: [productId],
          orderNo: orderNo,
          needCheckAvailable: false,
        );
        _putProductDetails(productDetailList);
        productDetails = _getProductDetails(productId);
        if (productDetails != null) break; // 成功获取则跳出循环
        retryCount--;
        var delayMillis = getRetryDelayMillis(retryCount);
        // 延迟 delayMillis 毫秒秒后重试
        if (delayMillis > 0) {
          await Future.delayed(Duration(milliseconds: delayMillis));
        }
      }
    }

    if (productDetails == null) {
      _onError(
        source: "checkProductDetails",
        productId: productId,
        orderNo: orderNo,
        errorMsg: "product details is null",
      );
      return false;
    }

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
        errorMsg: "buyConsumable result: $result",
      );
      return result;
    } catch (e) {
      _onError(
        source: "buyConsumable_catch",
        productId: productId,
        orderNo: orderNo,
        errorMsg: e.toString(),
      );
      return false;
    }
  }

  /// 处理购买更新
  /// 注意：调用InAppPurchase.instance.restorePurchases()后，如果没有需要补单，purchaseDetailsList为空
  /// TODO 注意：iOS 在重启后调用 await InAppPurchase.instance.restorePurchases()，才能获取到补单数据；退出登录时获取不到，需要另外处理！
  void _handlePurchaseUpdate(List<PurchaseDetails>? purchaseDetailsList) {
    if (purchaseDetailsList == null || purchaseDetailsList.isEmpty) {
      return;
    }
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
          source: iapError?.source ?? "",
          productId: purchaseDetails.productID,
          errorCode: iapError?.code,
          errorMsg: iapError?.message,
          details: purchaseDetails,
        );

        if (purchaseDetails.pendingCompletePurchase) {
          _completePurchase(purchaseDetails, purchaseDetails.status);
        }
      } else if (purchaseDetails.status == PurchaseStatus.canceled) {
        // 取消
        _onCanceled(purchaseDetails);

        if (purchaseDetails.pendingCompletePurchase) {
          _completePurchase(purchaseDetails, purchaseDetails.status);
        }
      } else if (purchaseDetails.status == PurchaseStatus.purchased ||
          purchaseDetails.status == PurchaseStatus.restored) {
        var result = await _verifyPurchase(purchaseDetails);
        if (result.isValid) {
          _deliverProduct(result.orderModel);

          // 只有服务器校验通过并下发商品后，才调用 completePurchase 结束 App Store/Google Play 的事务
          if (purchaseDetails.pendingCompletePurchase) {
            _completePurchase(purchaseDetails, purchaseDetails.status);
          }
        } else {
          _handleInvalidPurchase(purchaseDetails, result);
        }

        // 补单上报埋点
        if (purchaseDetails.status == PurchaseStatus.restored) {
          _log(
            'restore_purchase',
            productId: purchaseDetails.productID,
            orderNo: result.orderModel.orderNo,
            errorMsg: "restore purchase statistics",
          );
        }
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
  Future<void> _completePurchase(
    PurchaseDetails purchaseDetails,
    PurchaseStatus status,
  ) async {
    try {
      await _inAppPurchase.completePurchase(purchaseDetails);
    } catch (e) {
      _log(
        'completePurchase_catch',
        productId: purchaseDetails.productID,
        errorCode: "-1",
        errorMsg: "purchaseStatus: ${status.name}, e: ${e.toString()}",
      );
    }
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
      errorMsg: purchaseDetails.error?.toString(),
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

  /// 获取重试的延迟毫秒数
  int getRetryDelayMillis(int retryCount) {
    int delayMilliseconds;
    switch (retryCount) {
      case 2: // 第一次重试
        delayMilliseconds = 500;
        break;
      case 1: // 第二次重试
        delayMilliseconds = 1000;
        break;
      case 0: // 第三次重试
        delayMilliseconds = 2000;
        break;
      default:
        delayMilliseconds = 0;
        break;
    }
    return delayMilliseconds;
  }
}
