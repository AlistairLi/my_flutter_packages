import 'package:facebook_wrapper/src/interfaces/facebook_config_interface.dart';
import 'package:facebook_wrapper/src/interfaces/facebook_error_interface.dart';
import 'package:fb_sdk_flutter/fb_sdk_flutter.dart';

class FacebookWrapperService {
  final String _tag = "FacebookService";

  FacebookSDK? _fb;
  final FacebookConfigInterface _config;
  final FacebookErrorInterface _error;

  FacebookWrapperService({
    required FacebookConfigInterface config,
    required FacebookErrorInterface error,
  })  : _config = config,
        _error = error;

  Future<void> initialize() async {
    if (_fb != null) return;
    var serId = await _config.serverId ?? "";
    var serToken = await _config.serverToken ?? "";
    String finalId = serId.isEmpty ? _config.defaultId : serId;
    String finalToken = serToken.isEmpty ? _config.defaultToken : serToken;
    if (finalId.isEmpty || finalToken.isEmpty) return;

    _fb = FacebookSDK();
    _fb!.sdkInit(applicationId: finalId, clientToken: finalToken);
  }

  void uploadPurchaseEvent(double price) {
    try {
      logEvent("custom_purchase", price);
      logPurchase(price, "USD");
    } catch (e) {
      _error.onError(
          event: 'uploadPurchase_catch', source: _tag, errorMsg: e.toString());
    }
  }

  void logEvent(String eventName, double valueToSum) {
    _fb?.logEvent(eventName: eventName, parameters: {"valueToSum": valueToSum});
  }

  void logPurchase(double price, String currency) {
    _fb?.logPurchase(purchaseAmount: price, currency: currency);
  }
}
