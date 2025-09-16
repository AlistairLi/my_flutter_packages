class UnifiedDeviceInfo {
  /// 设备平台, eg: Android, iOS
  final String platform;

  /// 操作系统版本, eg: 13, 18.5
  final String osVersion;

  /// SDK版本, eg: 34, iPhone17,4
  final String sdkVersion;

  /// 用户可识别的设备名称, eg: Pixel 6, iPhone 16 Plus
  final String deviceName;

  /// 设备型号, eg: Pixel 6, iPhone 16 Plus
  final String deviceModel;

  /// 设备品牌, eg: google, apple
  final String brand;

  /// 设备生产厂商, eg: Google, Apple
  final String manufacturer;

  /// 处理器名称, eg: oriole
  final String processorName;

  /// 是否真机
  final bool isPhysicalDevice;

  /// 设备唯一标识符, 即 DeviceId
  final String identifier;

  UnifiedDeviceInfo({
    required this.platform,
    required this.sdkVersion,
    required this.deviceName,
    required this.deviceModel,
    required this.brand,
    required this.manufacturer,
    required this.processorName,
    required this.osVersion,
    required this.isPhysicalDevice,
    required this.identifier,
  });
}
