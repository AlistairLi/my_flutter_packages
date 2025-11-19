import 'dart:io';

import 'package:app_device_info_service/src/unified_device_info.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_udid/flutter_udid.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// 应用信息,设备信息工具类
/// 主要获取静态的不会修改的数据，时区等可以修改的数据不在这里获取
class AppDeviceInfoService {
  AppDeviceInfoService._();

  /// 存储iOS设备唯一标识符的key
  static final String _iosIdentifierKey = "iosIdentifierKey";

  /// 包信息
  static PackageInfo? _packageInfo;

  /// iOS设备信息
  static IosDeviceInfo? _iosDeviceInfo;

  /// 安卓设备信息
  static AndroidDeviceInfo? _androidDeviceInfo;

  /// 设备信息
  static UnifiedDeviceInfo? _unifiedDeviceInfo;

  static int? get androidSdkInt => _androidDeviceInfo?.version.sdkInt;

  static String get androidSdkVersion =>
      _androidDeviceInfo?.version.sdkInt.toString() ?? "";

  static String get androidHardware => _androidDeviceInfo?.hardware ?? "";

  static String get iosSystemVersion => _iosDeviceInfo?.systemVersion ?? "";

  static String get iosMachine => _iosDeviceInfo?.utsname.machine ?? "";

  static String get platform => _unifiedDeviceInfo?.platform ?? "Unknown";

  static String get osVersion => _unifiedDeviceInfo?.osVersion ?? "Unknown";

  static String get sdkVersion => _unifiedDeviceInfo?.sdkVersion ?? "Unknown";

  static String get deviceName => _unifiedDeviceInfo?.deviceName ?? "Unknown";

  static String get deviceModel => _unifiedDeviceInfo?.deviceModel ?? "Unknown";

  static String get brand => _unifiedDeviceInfo?.brand ?? "Unknown";

  static String get manufacturer =>
      _unifiedDeviceInfo?.manufacturer ?? "Unknown";

  static String get processorName =>
      _unifiedDeviceInfo?.processorName ?? "Unknown";

  static bool get isPhysicalDevice =>
      _unifiedDeviceInfo?.isPhysicalDevice ?? false;

  static String get deviceId => _unifiedDeviceInfo?.identifier ?? "Unknown";

  static String get appVersion => _packageInfo?.version ?? "";

  static String get appBuildNumber => _packageInfo?.buildNumber ?? "";

  static String get appName => _packageInfo?.appName ?? "";

  static String get appPackageName => _packageInfo?.packageName ?? "";

  static Future<void> initData() async {
    // 获取包信息
    _packageInfo = await PackageInfo.fromPlatform();

    // 获取设备信息
    DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      _androidDeviceInfo = await deviceInfoPlugin.androidInfo;
      _unifiedDeviceInfo = UnifiedDeviceInfo(
        platform: "Android",
        osVersion: _androidDeviceInfo?.version.release ?? "Unknown",
        sdkVersion: _androidDeviceInfo?.version.sdkInt.toString() ?? "Unknown",
        deviceName: _androidDeviceInfo?.name ?? "Unknown",
        deviceModel: _androidDeviceInfo?.model ?? "Unknown",
        brand: _androidDeviceInfo?.brand ?? "Unknown",
        manufacturer: _androidDeviceInfo?.manufacturer ?? "Unknown",
        processorName: _androidDeviceInfo?.hardware ?? "Unknown",
        isPhysicalDevice: _androidDeviceInfo?.isPhysicalDevice ?? false,
        identifier: await FlutterUdid.udid,
      );
    } else if (Platform.isIOS) {
      _iosDeviceInfo = await deviceInfoPlugin.iosInfo;
      String identifier;
      // 从钥匙串读取iOS设备ID
      const storage = FlutterSecureStorage();
      String? value = await storage.read(key: _iosIdentifierKey);
      if (value != null && value.isNotEmpty) {
        identifier = value;
      } else {
        // 如果不存在则取设备的idFv作为唯一标识
        identifier = _iosDeviceInfo?.identifierForVendor ?? "";
        storage.write(key: _iosIdentifierKey, value: identifier);
      }

      _unifiedDeviceInfo = UnifiedDeviceInfo(
        platform: "iOS",
        osVersion: _iosDeviceInfo?.systemVersion ?? "Unknown",
        sdkVersion: _iosDeviceInfo?.utsname.machine ?? "Unknown",
        deviceName: _iosDeviceInfo?.name ?? "Unknown",
        deviceModel: _iosDeviceInfo?.modelName ?? "Unknown",
        brand: "Apple",
        manufacturer: "Apple",
        processorName: "",
        isPhysicalDevice: _iosDeviceInfo?.isPhysicalDevice ?? false,
        identifier: identifier,
      );
    }
  }
}
