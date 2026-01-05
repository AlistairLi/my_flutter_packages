import 'package:inapp_purchase_wrapper/inapp_purchase_wrapper.dart';

class GooglePlayOrderModel extends IapOrderModel {
  String originalJson;
  String? signature;

  GooglePlayOrderModel({
    required super.orderNo,
    super.purchaseID,
    required super.productId,
    super.price,
    super.rawPrice,
    super.currencyCode,
    super.currencySymbol,
    super.uPrice,
    required this.originalJson,
    required this.signature,
  });

  factory GooglePlayOrderModel.fromJson(Map<String, dynamic> json) {
    final parent = IapOrderModel.fromJson(json);
    return GooglePlayOrderModel(
      orderNo: parent.orderNo,
      purchaseID: parent.purchaseID,
      productId: parent.productId,
      price: parent.price,
      rawPrice: parent.rawPrice,
      currencyCode: parent.currencyCode,
      currencySymbol: parent.currencySymbol,
      uPrice: parent.uPrice,
      originalJson: json['originalJson'] ?? '',
      signature: json['signature'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['originalJson'] = originalJson;
    json['signature'] = signature;
    return json;
  }
}
