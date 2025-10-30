abstract class IInAppStorage {
  Future<void> saveOrderData(String orderNo, Map<String, dynamic> orderMap);

  Future<Map<String, dynamic>?> getOrderData(String orderNo);

  /// 通过 purchaseID 获取本地订单数据
  Future<Map<String, dynamic>?> getOrderDataFromPurId(String purchaseID);

  Future<void> updateOrderData(String orderNo, Map<String, dynamic> orderMap);

  Future<void> removeOrder(String orderNo);
}
