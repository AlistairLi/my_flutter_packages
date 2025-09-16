import 'dart:convert';

import 'package:adjust_sdk/adjust.dart';
import 'package:adjust_sdk/adjust_attribution.dart';
import 'package:adjust_sdk/adjust_config.dart';
import 'package:adjust_sdk/adjust_event.dart';
import 'package:aj_wrapper/src/interfaces/aj_config_interface.dart';
import 'package:aj_wrapper/src/interfaces/aj_error_interface.dart';
import 'package:aj_wrapper/src/interfaces/aj_storage_interface.dart';

/// Adjust 工具
class AJWrapperService {
  final String _tag = "AdjustService";
  final String _keyAdjustData = "key_adjust_data";

  final AJStorageInterface _storage;
  final AJConfigInterface _config;
  final AJErrorInterface _error;

  AdjustAttribution? _adjustAttribution;

  AdjustAttribution? get adjustAttribution => _adjustAttribution;

  String? _adjustSdkVersion;
  bool _isInitialized = false;

  String get adjustSdkVersion => _adjustSdkVersion ?? "";

  AJWrapperService({
    required AJStorageInterface storage,
    required AJConfigInterface config,
    required AJErrorInterface error,
  })  : _storage = storage,
        _config = config,
        _error = error;

  /// 初始化 Adjust, 一次生命周期只初始化一次
  void initialize() async {
    if (_isInitialized == true) {
      return;
    }
    _isInitialized = true;

    var isRelease = _config.isRelease;
    AdjustEnvironment environment =
        isRelease ? AdjustEnvironment.production : AdjustEnvironment.sandbox;

    AdjustConfig config = AdjustConfig(_config.appToken, environment);
    config.logLevel =
        isRelease ? AdjustLogLevel.suppress : AdjustLogLevel.verbose;
    config.attributionCallback = (AdjustAttribution attributionChangedData) {
      _adjustAttribution = attributionChangedData;
      _executeUpload(attributionChangedData);
      _saveAJDataToLocal();
    };
    Adjust.start(config);

    try {
      _adjustSdkVersion = (await Adjust.getSdkVersion()).split("@")[1];
    } catch (e) {
      _error.onError(
          event: 'getSdkVersion_catch', source: _tag, errorMsg: e.toString());
    }
  }

  /// 上报归因数据集
  void uploadAdjustData() async {
    await _fetchAJDataFromLocal();
    _executeUpload(_adjustAttribution);
  }

  /// 上报购买事件
  void uploadPurchaseEvent(double price) {
    try {
      AdjustEvent adjustEvent = AdjustEvent(_config.purchaseToken);
      adjustEvent.setRevenue(price, "USD");
      Adjust.trackEvent(adjustEvent);
    } catch (e) {
      _error.onError(
          event: 'uploadPurchaseEvent_catch',
          source: _tag,
          errorMsg: "price: $price, error:${e.toString()}");
    }
  }

  /// 从本地获取数据
  Future<AdjustAttribution?> _fetchAJDataFromLocal() async {
    if (_adjustAttribution == null) {
      try {
        String? localStr = await _storage.getString(_keyAdjustData);
        if (localStr == null || localStr.isEmpty) {
          return null;
        }
        _adjustAttribution = AdjustAttribution.fromMap(jsonDecode(localStr));
      } catch (e) {
        _error.onError(
            event: 'fetchFromLocal_catch',
            source: _tag,
            errorMsg: e.toString());
      }
    }
    return _adjustAttribution;
  }

  /// 保存归因数据到本地
  void _saveAJDataToLocal() async {
    try {
      if (_adjustAttribution == null) {
        return;
      }
      Map adjustMap = _ajDataToMap(_adjustAttribution!);
      await _storage.saveString(_keyAdjustData, jsonEncode(adjustMap));
    } catch (e) {
      _error.onError(
          event: 'saveFromLocal_catch', source: _tag, errorMsg: e.toString());
    }
  }

  Map<String, String> _ajDataToMap(AdjustAttribution attribution) {
    return {
      'campaign': attribution.campaign ?? '',
      'trackerToken': attribution.trackerToken ?? '',
      'trackerName': attribution.trackerName ?? '',
      'network': attribution.network ?? '',
      'creative': attribution.creative ?? '',
      'clickLabel': attribution.clickLabel ?? '',
      'costType': attribution.costType ?? '',
      'adgroup': attribution.adgroup ?? '',
      'costCurrency': attribution.costCurrency ?? '',
      'fbInstallReferrer': attribution.fbInstallReferrer ?? '',
    };
  }

  /// 上报归因数据到后台
  void _executeUpload(AdjustAttribution? attributionChangedData) async {
    if (attributionChangedData == null) {
      return;
    }

    final shouldUpload = await _config.shouldUploadAttributionData();
    if (!shouldUpload) return;

    final success = await _config.uploadAttributionData(attributionChangedData);
    if (!success) {
      _error.onError(event: 'uploadData_failed', source: _tag);
    }
  }
}
