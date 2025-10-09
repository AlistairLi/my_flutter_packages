abstract class IInAppStorage {
  Future<void> saveOrderData(String orderNo, Map<String, dynamic> orderMap);

  Future<Map<String, dynamic>?> getOrderData(String orderNo);

  Future<void> updateOrderData(String orderNo, Map<String, dynamic> orderMap);

  Future<void> removeOrder(String orderNo);
}
