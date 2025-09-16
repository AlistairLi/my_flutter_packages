import 'dart:io';

import 'package:appsflyer_wrapper/src/interfaces/af_config_interface.dart';
import 'package:appsflyer_wrapper/src/interfaces/af_error_interface.dart';
import 'package:appsflyer_wrapper/src/model/appsflyer_args.dart';
import 'package:appsflyer_sdk/appsflyer_sdk.dart';

/// Appsflyer 工具
class AFWrapperService {
  final String _tag = "AppsflyerService";

  AppsflyerSdk? _appsflyerSdk;

  AppsflyerArgs? _appsflyerArgs;

  AppsflyerArgs? get appsflyerArgs => _appsflyerArgs;

  String? _appsflyerSdkVersion;

  String get appsflyerSdkVersion => _appsflyerSdkVersion ?? "";

  final AFConfigInterface _config;
  final AFErrorInterface _error;

  bool _isInitialized = false;

  AFWrapperService({
    required AFConfigInterface config,
    required AFErrorInterface error,
  })  : _config = config,
        _error = error;

  /// 初始化 Appsflyer, 一次生命周期只初始化一次
  void initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;

    AppsFlyerOptions options = AppsFlyerOptions(
      afDevKey: Platform.isAndroid
          ? _config.appsflyerAndroidKey
          : _config.appsflyerIOSKey,
      appId: Platform.isIOS ? _config.appleId : "",
      showDebug: !_config.isRelease,
      timeToWaitForATTUserAuthorization: 15,
    );
    _appsflyerSdk = AppsflyerSdk(options);

    _appsflyerSdk!.onInstallConversionData((res) {
      if (res != null && res["status"] == "success" && res["payload"] != null) {
        try {
          var args = AppsflyerArgs.fromJson(res["payload"]);
          _appsflyerArgs = args;
          _uploadAppsflyerData(args);
        } catch (e) {
          _error.onError(
              event: 'onInstallConversionData_catch',
              source: _tag,
              errorMsg: e.toString());
        }
      }
    });

    _appsflyerSdk!.initSdk(
        registerConversionDataCallback: true,
        registerOnAppOpenAttributionCallback: true,
        registerOnDeepLinkingCallback: true);

    _initSdkVersion();
  }

  void _uploadAppsflyerData(AppsflyerArgs data) async {
    final shouldUpload = await _config.shouldUploadAttributionData();
    if (!shouldUpload) return;
    final success =
        await _config.uploadAttributionData(data);
    if (!success) {
      _error.onError(event: 'uploadData_failed', source: _tag);
    }
  }

  void _initSdkVersion() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    try {
      _appsflyerSdkVersion = await _appsflyerSdk?.getSDKVersion();
    } catch (e) {
      _error.onError(
          event: 'getSdkVersion_catch', source: _tag, errorMsg: e.toString());
    }
  }

  /// 上报事件
  void logEvent(String eventName, Map? eventValues) async {
    try {
      var result = await _appsflyerSdk?.logEvent(eventName, eventValues);
      if (result != true) {
        _error.onError(event: '${eventName}_failed', source: _tag);
      }
    } catch (e) {
      _error.onError(
          event: '${eventName}_catch', source: _tag, errorMsg: e.toString());
    }
  }

  /// 上报购买事件
  void uploadPurchaseEvent(double price) {
    logEvent('af_purchase', {
      'af_revenue': price,
      'af_price': price,
      'af_currency': 'USD',
    });
  }
}
