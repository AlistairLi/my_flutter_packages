import 'package:app_device_info_service/app_device_info_service.dart';

void main() async {
  // Initialization is performed when the application starts.
  await AppDeviceInfoService.initData();

  // Usage
  var packageName = AppDeviceInfoService.appPackageName;
  var appVersion = AppDeviceInfoService.appVersion;
  var deviceId = AppDeviceInfoService.deviceId;
  var deviceName = AppDeviceInfoService.deviceName;
  // ...
}
