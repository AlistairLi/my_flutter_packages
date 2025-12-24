import 'package:inapp_purchase_wrapper/inapp_purchase_wrapper.dart';

/// 内部存储包装类
///
/// 包装调用方实现的 [IInAppStorage]，并添加内存缓存层
/// 优先从内存获取数据，内存未命中时再从本地存储获取
class InAppStorageWrapper implements IInAppStorage {
  final IInAppStorage _externalStorage;

  IIAPLogger? logger;

  /// 订单内存缓存 (orderNo -> orderData)
  final Map<String, Map<String, dynamic>> _orderMemoryCache = {};

  /// purchaseID -> orderNo 映射
  final Map<String, String> _purchaseIdToOrderNoCache = {};

  InAppStorageWrapper(this._externalStorage, this.logger);

  @override
  Future<void> saveOrderData(
      String orderNo, Map<String, dynamic> orderMap) async {
    if (orderNo.isEmpty) return;

    // 先保存到内存缓存
    _orderMemoryCache[orderNo] = Map.from(orderMap);

    // 再保存到外部存储
    try {
      await _externalStorage.saveOrderData(orderNo, orderMap);
    } catch (e) {
      _log(
        'externalStorageError_saveOrderData',
        orderNo: orderNo,
        errorCode: '-1',
        errorMsg: e.toString(),
      );
    }
  }

  @override
  Future<Map<String, dynamic>?> getOrderData(String orderNo) async {
    if (orderNo.isEmpty) return null;

    // 优先从内存获取
    final memoryData = _orderMemoryCache[orderNo];
    if (memoryData != null && memoryData.isNotEmpty) {
      return Map.from(memoryData);
    }

    // 内存未命中，从外部存储获取
    try {
      final externalData = await _externalStorage.getOrderData(orderNo);
      if (externalData != null && externalData.isNotEmpty) {
        // 回填到内存缓存
        _orderMemoryCache[orderNo] = Map.from(externalData);
        final purchaseID = externalData['purchaseID'] as String?;
        if (purchaseID != null && purchaseID.isNotEmpty) {
          _purchaseIdToOrderNoCache[purchaseID] = orderNo;
        }
      }
      return externalData;
    } catch (e) {
      _log(
        'externalStorageError_getOrderData',
        productId: memoryData?['productId'] as String?,
        orderNo: orderNo,
        errorCode: '-1',
        errorMsg: e.toString(),
      );
    }
    return null;
  }

  @override
  Future<Map<String, dynamic>?> getOrderDataFromPurId(String purchaseID) async {
    if (purchaseID.isEmpty) return null;

    // 优先从内存映射查找
    final orderNo = _purchaseIdToOrderNoCache[purchaseID];
    if (orderNo != null) {
      final memoryData = _orderMemoryCache[orderNo];
      if (memoryData != null && memoryData.isNotEmpty) {
        return Map.from(memoryData);
      }
    }

    // 内存未命中，从外部存储获取
    try {
      final externalData =
          await _externalStorage.getOrderDataFromPurId(purchaseID);
      if (externalData != null && externalData.isNotEmpty) {
        // 回填到内存缓存
        final extOrderNo = externalData['orderNo'] as String?;
        if (extOrderNo != null && extOrderNo.isNotEmpty) {
          _orderMemoryCache[extOrderNo] = Map.from(externalData);
          _purchaseIdToOrderNoCache[purchaseID] = extOrderNo;
        }
      }
      return externalData;
    } catch (e) {
      _log(
        'externalStorageError_getOrderDataFromPurId',
        orderNo: orderNo,
        errorCode: '-1',
        errorMsg: "purchaseID: $purchaseID, error: ${e.toString()}",
      );
    }
    return null;
  }

  @override
  Future<void> updateOrderData(
      String orderNo, Map<String, dynamic> orderMap) async {
    if (orderNo.isEmpty) return;

    // 先更新内存缓存
    _orderMemoryCache[orderNo] = Map.from(orderMap);

    // 更新 purchaseID 映射
    final purchaseID = orderMap['purchaseID'] as String?;
    if (purchaseID != null && purchaseID.isNotEmpty) {
      _purchaseIdToOrderNoCache[purchaseID] = orderNo;
    }

    // 再更新外部存储
    try {
      await _externalStorage.updateOrderData(orderNo, orderMap);
    } catch (e) {
      _log(
        'externalStorageError_updateOrderData',
        orderNo: orderNo,
        errorCode: '-1',
        errorMsg: e.toString(),
      );
    }
  }

  @override
  Future<void> removeOrder(String orderNo) async {
    if (orderNo.isEmpty) return;

    // 先从内存删除
    final orderData = _orderMemoryCache.remove(orderNo);
    if (orderData != null) {
      final purchaseID = orderData['purchaseID'] as String?;
      if (purchaseID != null && purchaseID.isNotEmpty) {
        _purchaseIdToOrderNoCache.remove(purchaseID);
      }
    }

    // 再从外部存储删除
    try {
      await _externalStorage.removeOrder(orderNo);
    } catch (e) {
      _log(
        'externalStorageError_removeOrder',
        orderNo: orderNo,
        errorCode: '-1',
        errorMsg: e.toString(),
      );
    }
  }

  /// 清空内存缓存（可选，用于登出等场景）
  void clearMemoryCache() {
    _orderMemoryCache.clear();
    _purchaseIdToOrderNoCache.clear();
  }

  /// 记录日志
  void _log(
    String event, {
    String? productId,
    String? orderNo,
    String? errorCode,
    String? errorMsg,
  }) {
    logger?.log(event,
        productId: productId,
        orderNo: orderNo,
        errorCode: errorCode,
        errorMsg: errorMsg);
  }
}
