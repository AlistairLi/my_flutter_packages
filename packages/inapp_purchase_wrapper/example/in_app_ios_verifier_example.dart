import 'package:inapp_purchase_wrapper/inapp_purchase_wrapper.dart';

class InAppIosVerifierExample extends IInAppVerifier {
  @override
  Future<VerifyResult> verify(IapOrderModel data) async {
    var orderModel = data as AppStoreOrderModel;
    // 调用项目的服务器接口验单
    return VerifyResult(
      isValid: true,
      errorCode: "0",
      errorMsg: "success",
      orderModel: data,
    );
  }
}
