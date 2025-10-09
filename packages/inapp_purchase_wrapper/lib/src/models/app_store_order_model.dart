import 'package:inapp_purchase_wrapper/inapp_purchase_wrapper.dart';

class AppStoreOrderModel extends IapOrderModel {
  String serverVerificationData;

  AppStoreOrderModel({
    required super.orderNo,
    required super.purchaseID,
    required super.productId,
    required super.price,
    required super.rawPrice,
    required super.currencyCode,
    required super.currencySymbol,
    required this.serverVerificationData,
  });

  factory AppStoreOrderModel.fromJson(Map<String, dynamic> json) {
    final parent = IapOrderModel.fromJson(json);
    return AppStoreOrderModel(
      orderNo: parent.orderNo,
      purchaseID: parent.purchaseID,
      productId: parent.productId,
      price: parent.price,
      rawPrice: parent.rawPrice,
      currencyCode: parent.currencyCode,
      currencySymbol: parent.currencySymbol,
      serverVerificationData: json['serverVerificationData'] ?? '',
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['serverVerificationData'] = serverVerificationData;
    return json;
  }
}
