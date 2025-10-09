import 'package:inapp_purchase_wrapper/inapp_purchase_wrapper.dart';

class VerifyResult {
  final bool isValid;
  final String? errorCode;
  final String? errorMsg;
  final IapOrderModel orderModel;

  VerifyResult({
    required this.isValid,
    required this.orderModel,
    this.errorCode,
    this.errorMsg,
  });

  factory VerifyResult.invalid({String? errorCode = "-1", String? errorMsg}) {
    return VerifyResult(
      isValid: false,
      errorCode: errorCode,
      errorMsg: errorMsg,
      orderModel: IapOrderModel(),
    );
  }
}
