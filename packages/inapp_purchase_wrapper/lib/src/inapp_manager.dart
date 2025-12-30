import 'dart:async';
import 'dart:io';

import 'package:inapp_purchase_wrapper/inapp_purchase_wrapper.dart';
import 'package:inapp_purchase_wrapper/src/enum/load_product_details_source.dart';
import 'package:inapp_purchase_wrapper/src/platform/i_inapp_platform.dart';
import 'package:inapp_purchase_wrapper/src/storage/inapp_storage_wrapper.dart';
import 'package:uuid/uuid.dart';

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
  bool _kAutoConsume = Platform.isIOS || true;

  /// 设置自动消耗
  /// 注意：非必要不要设置该值，设置了也不要频繁更改，否则可能会影响到补单。
  set kAutoConsume(bool value) {
    if (!Platform.isIOS) {
      _kAutoConsume = value;
    }
  }

  final IInAppPlatform _inAppPlatform;

  /// 内购监听回调
  final PaymentListener _paymentListener;

  /// 商品验单
  final IInAppVerifier _inAppVerifier;

  /// 带内存缓存的存储包装器
  final InAppStorageWrapper _inAppStorage;

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
        _inAppStorage = InAppStorageWrapper(inAppStorage, logger),
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
        'purchase_listen',
        errorMsg: 'onDone, Internal purchase monitoring complete',
      );
    }, onError: (error) {
      _log(
        'purchase_listen',
        errorCode: '-1',
        errorMsg: 'error: ${error.toString()}',
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
      source: LoadProductDetailsSource.preload,
    );
    _putProductDetails(productDetailsList);
  }

  /// 清空商品详情缓存
  void clearProductDetailsCache() {
    _productDetailsCache.clear();
  }

  /// 清空订单内存缓存（用于登出等场景）
  void clearOrderMemoryCache() {
    _inAppStorage.clearMemoryCache();
  }

  /// 向商店请求商品详情
  Future<List<ProductDetails>> _loadProductDetails({
    required List<String> productIds,
    required LoadProductDetailsSource source,
    String? orderNo,
  }) async {
    String? uuid;
    int? startTime;

    if (source == LoadProductDetailsSource.preload) {
      startTime = DateTime.now().millisecondsSinceEpoch;
      uuid = const Uuid().v4();
    }

    _log(
      'review_order',
      productId: productIds.toString(),
      uuid: uuid,
      elapsedTime: 0,
    );

    if (productIds.isEmpty) {
      _log(
        "review_order_resp",
        productId: productIds.toString(),
        orderNo: orderNo,
        errorCode: '-1',
        errorMsg: 'error: parameter productIds is empty',
        uuid: uuid,
        elapsedTime: startTime != null
            ? DateTime.now().millisecondsSinceEpoch - startTime
            : null,
      );
      return [];
    }

    if (source == LoadProductDetailsSource.preload) {
      final bool available = await _inAppPurchase.isAvailable();
      if (!available) {
        _log(
          "review_order_resp",
          productId: productIds.toString(),
          orderNo: orderNo,
          errorCode: '-1',
          errorMsg: "error: InAppPurchase.isAvailable: $available",
          uuid: uuid,
          elapsedTime: startTime != null
              ? DateTime.now().millisecondsSinceEpoch - startTime
              : null,
        );
        return [];
      }
    }

    ProductDetailsResponse response =
        await _inAppPurchase.queryProductDetails(productIds.toSet());

    if (response.error != null) {
      _log(
        "review_order_resp",
        productId: productIds.toString(),
        orderNo: orderNo,
        errorCode: '-1',
        errorMsg: 'error: ${response.error?.toString()}',
        uuid: uuid,
        elapsedTime: startTime != null
            ? DateTime.now().millisecondsSinceEpoch - startTime
            : null,
      );
      return [];
    }

    if (response.productDetails.isEmpty) {
      _log(
        "review_order_resp",
        productId: productIds.toString(),
        orderNo: orderNo,
        errorCode: '-1',
        errorMsg: "error: ProductDetailsResponse.productDetails is empty",
        uuid: uuid,
        elapsedTime: startTime != null
            ? DateTime.now().millisecondsSinceEpoch - startTime
            : null,
      );
      return [];
    }

    var ids = response.productDetails.map((e) => e.id).toList();
    _log(
      "review_order_resp",
      productId: productIds.toString(),
      orderNo: orderNo,
      errorCode: '0',
      errorMsg: "success, productIds: ${ids.toString()}",
      uuid: uuid,
      elapsedTime: startTime != null
          ? DateTime.now().millisecondsSinceEpoch - startTime
          : null,
    );

    return response.productDetails;
  }

  /// 将 List<ProductDetails> 缓存到 _productDetailsCache中
  void _putProductDetails(List<ProductDetails> productDetailsList) {
    if (productDetailsList.isEmpty) return;
    for (var value in productDetailsList) {
      _productDetailsCache[value.id] = value;
    }
  }

  /// 获取单个商品详情
  ProductDetails? _getProductDetails(String productId) {
    if (productId.isEmpty) return null;
    return _productDetailsCache[productId];
  }

  /// 启动购买
  ///
  /// [productId] 商品 code
  /// [orderNo] 订单号
  /// [uPrice] 美元价格
  Future<bool> startPurchase({
    required String? productId,
    required String? orderNo,
    double? uPrice,
  }) async {
    if (productId == null || productId.isEmpty) {
      _onError(
        event: "launch_pay",
        productId: productId,
        orderNo: orderNo,
        errorMsg: "error: productId is empty",
      );
      return false;
    }
    if (orderNo == null || orderNo.isEmpty) {
      _onError(
        event: "launch_pay",
        productId: productId,
        orderNo: orderNo,
        errorMsg: "error: orderNo is empty",
      );
      return false;
    }

    // 检查服务是否可用
    final bool available = await _inAppPurchase.isAvailable();
    if (!available) {
      _onError(
        event: "launch_pay",
        productId: productId,
        orderNo: orderNo,
        errorMsg: "error: InAppPurchase.isAvailable: $available",
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
          source: LoadProductDetailsSource.purchase,
          orderNo: orderNo,
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
        event: "launch_pay",
        productId: productId,
        orderNo: orderNo,
        errorMsg: "error: productDetails is null",
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
        uPrice: uPrice,
      );
      _inAppStorage.saveOrderData(orderNo, order.toJson());

      _log(
        'launch_pay',
        productId: productId,
        orderNo: orderNo,
        errorCode: result ? "0" : "-1",
        errorMsg:
            "${result ? "success" : "failed"}, autoConsume: $_kAutoConsume, product details: ${_inAppPlatform.getProductDetailsInfo(productDetails)}",
      );
      return result;
    } catch (e) {
      _onError(
        event: "launch_pay",
        productId: productId,
        orderNo: orderNo,
        errorMsg: "error: ${e.toString()}",
      );
    }
    return false;
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
    var orderModel = await _inAppPlatform.getOrderModel(
      storage: _inAppStorage,
      purchaseDetails: purchaseDetails,
    );
    var iapError = purchaseDetails.error;
    _log(
      'launch_pay_resp',
      productId: purchaseDetails.productID,
      orderNo: orderModel?.orderNo,
      errorCode: purchaseDetails.status.name,
      errorMsg:
          "purchaseID: ${purchaseDetails.purchaseID}${iapError != null ? ", ${iapError.toString()}" : ""}${orderModel != null ? ", ${orderModel.toString()}" : ""}",
    );

    if (purchaseDetails.status == PurchaseStatus.pending) {
      // 等待中
      _paymentListener.onPending(purchaseDetails);
    } else {
      if (purchaseDetails.status == PurchaseStatus.error) {
        // 错误
        _paymentListener.onError(
          IAPError(
            source: 'launch_pay_resp',
            code: iapError?.code ?? '',
            message: iapError?.message ?? '',
            details: purchaseDetails,
          ),
        );
      } else if (purchaseDetails.status == PurchaseStatus.canceled) {
        // 取消
        _paymentListener.onCanceled(purchaseDetails);
      } else if (purchaseDetails.status == PurchaseStatus.purchased ||
          purchaseDetails.status == PurchaseStatus.restored) {
        var result = await _verifyPurchase(purchaseDetails, orderModel);

        if (result.isValid) {
          _deliverProduct(result.orderModel);
        } else {
          _handleInvalidPurchase(purchaseDetails, result);
          return;
        }
      }

      _completePurchase(purchaseDetails, orderModel?.orderNo);
    }
  }

  Future<VerifyResult> _verifyPurchase(
    PurchaseDetails purchaseDetails,
    IapOrderModel? orderModel,
  ) async {
    VerifyResult verifyResult;
    try {
      verifyResult = await _inAppPlatform.verifyPurchase(
        storage: _inAppStorage,
        orderModel: orderModel,
        verifier: _inAppVerifier,
      );
    } catch (e) {
      verifyResult = VerifyResult(
        isValid: false,
        errorCode: "-1",
        errorMsg: e.toString(),
        orderModel: IapOrderModel(
          productId: purchaseDetails.productID,
          purchaseID: purchaseDetails.purchaseID,
        ),
      );
    }
    return verifyResult;
  }

  void _deliverProduct(IapOrderModel orderModel) {
    _inAppStorage.removeOrder(orderModel.orderNo);

    try {
      _paymentListener.onSuccess(orderModel);
    } catch (e) {
      _log(
        'on_success',
        productId: orderModel.productId,
        orderNo: orderModel.orderNo,
        errorCode: "-1",
        errorMsg: "error: ${e.toString()}",
      );
    }
  }

  void _handleInvalidPurchase(
    PurchaseDetails purchaseDetails,
    VerifyResult result,
  ) {
    _onError(
      event: "verify_order_failed",
      productId: purchaseDetails.productID,
      orderNo: result.orderModel.orderNo,
      errorCode: result.errorCode,
      errorMsg:
          "purchaseStatus: ${purchaseDetails.status.name}, purchaseID: ${purchaseDetails.purchaseID}, error: ${result.errorMsg}",
      details: purchaseDetails,
    );
  }

  /// 完成购买
  Future<void> _completePurchase(
    PurchaseDetails purchaseDetails,
    String? orderNo,
  ) async {
    var subMsg = "purchaseID: ${purchaseDetails.purchaseID}";

    try {
      _log(
        'consume_order',
        productId: purchaseDetails.productID,
        orderNo: orderNo,
        errorCode: purchaseDetails.status.name,
        errorMsg: subMsg,
      );

      await _inAppPlatform.completePurchase(
        _inAppPurchase,
        purchaseDetails,
        autoConsume: _kAutoConsume,
        logger: _logger,
      );

      _log(
        'consume_order_resp',
        productId: purchaseDetails.productID,
        orderNo: orderNo,
        errorCode: purchaseDetails.status.name,
        errorMsg: 'success, $subMsg',
      );
    } catch (e) {
      _log(
        'consume_order_resp',
        productId: purchaseDetails.productID,
        errorCode: purchaseDetails.status.name,
        errorMsg: "error: ${e.toString()}, $subMsg",
      );
    }
  }

  /// 查询并补单
  void _restorePurchases() {
    try {
      _inAppPurchase.restorePurchases();
    } catch (e) {
      _log(
        'restore_purchases',
        errorCode: '-1',
        errorMsg: "error: ${e.toString()}",
      );
    }
  }

  void _onError(
      {required String event,
      String? productId,
      String? orderNo,
      String? errorCode,
      String? errorMsg,
      dynamic details}) {
    _log(
      event,
      productId: productId,
      orderNo: orderNo,
      errorCode: errorCode ?? '-1',
      errorMsg: errorMsg,
    );
    _paymentListener.onError(
      IAPError(
        source: event,
        code: errorCode ?? '',
        message: errorMsg ?? '',
        details: details,
      ),
    );
  }

  /// 记录日志
  void _log(
    String event, {
    String? productId,
    String? orderNo,
    String? errorCode,
    String? errorMsg,
    String? uuid,
    int? elapsedTime,
  }) {
    _logger?.log(
      event,
      productId: productId,
      orderNo: orderNo,
      errorCode: errorCode,
      errorMsg: errorMsg,
      uuid: uuid,
      elapsedTime: elapsedTime,
    );
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
