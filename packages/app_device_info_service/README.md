# app_device_info_service

A Dart package for retrieving comprehensive device and application information, including platform
details, OS version, device model, and unique identifiers across Android and iOS platforms.

## Installation

Add the dependency in `pubspec.yaml`:

```yaml 
dependencies:
  app_device_info_service: ^1.0.0
```

Then run:

``` bash
flutter pub get
```

## Usage

```dart
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

```

## Example

See the example directory for a complete sample app.

## License

The project is under the MIT license.