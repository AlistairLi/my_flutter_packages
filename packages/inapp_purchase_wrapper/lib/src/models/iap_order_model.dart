class IapOrderModel {
  /// 订单编号
  String orderNo;

  /// 购买ID, eg: 2000000123123123
  String? purchaseID;

  /// 商品ID
  String? productId;

  /// 价格, eg:$1.99
  String? price;

  /// 原始价格, eg: 1.99
  double? rawPrice;

  /// 币种, eg: USD
  String? currencyCode;

  /// 币种符号, eg: $
  String? currencySymbol;

  IapOrderModel({
    this.orderNo = "",
    this.purchaseID,
    this.productId,
    this.price,
    this.rawPrice,
    this.currencyCode,
    this.currencySymbol,
  });

  factory IapOrderModel.fromJson(Map<String, dynamic> json) {
    return IapOrderModel(
      orderNo: json['orderNo'],
      purchaseID: json['purchaseID'],
      productId: json['productId'],
      price: json['price'],
      rawPrice: json['rawPrice'],
      currencyCode: json['currencyCode'],
      currencySymbol: json['currencySymbol'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderNo': orderNo,
      'purchaseID': purchaseID,
      'productId': productId,
      'price': price,
      'rawPrice': rawPrice,
      'currencyCode': currencyCode,
      'currencySymbol': currencySymbol,
    };
  }
}
