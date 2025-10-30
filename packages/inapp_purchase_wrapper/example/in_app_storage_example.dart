import 'package:inapp_purchase_wrapper/inapp_purchase_wrapper.dart';

class InAppStorageImplExample extends IInAppStorage {
  @override
  Future<Map<String, dynamic>?> getOrderData(String orderNo) {
    // TODO: implement getOrderData
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>?> getOrderDataFromPurId(String purchaseID) {
    // TODO: implement getOrderDataFromPurId
    throw UnimplementedError();
  }

  @override
  Future<void> removeOrder(String orderNo) {
    // TODO: implement removeOrder
    throw UnimplementedError();
  }

  @override
  Future<void> saveOrderData(String orderNo, Map<String, dynamic> orderMap) {
    // TODO: implement saveOrderData
    throw UnimplementedError();
  }

  @override
  Future<void> updateOrderData(String orderNo, Map<String, dynamic> orderMap) {
    // TODO: implement updateOrderData
    throw UnimplementedError();
  }
}
