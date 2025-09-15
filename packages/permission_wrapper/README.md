# permission_wrapper

A Flutter permission management wrapper library based on permission_handler with enhanced features.

## Features

- ✅ **Batch Permission Management**: Check and request multiple permissions at once
- ✅ **Custom Permission Configuration**: Configure permission titles, descriptions, and messages
- ✅ **Permission Status Monitoring**: Listen to permission status changes with callbacks
- ✅ **Smart Retry Mechanism**: Automatic retry with configurable attempts
- ✅ **Platform Compatibility**: Android SDK version adaptation for photos permission
- ✅ **Permission History Tracking**: Track permission request history and results
- ✅ **Settings Integration**: Direct access to app settings for permanently denied permissions


## Installation
Add the dependency in `pubspec.yaml`:

```yaml 
dependencies:
  permission_wrapper: ^0.0.1
```

Then run:
``` bash
flutter pub get
```

## Usage

```dart
var resultInfo = await PermissionManager.checkPermission(
  PermissionType.camera,
  onAlert: (permissionType, result, message) async {
    return showPermissionDeniedDialog(
      context,
      'Rejected the camera permission',
    );
  },
);
return resultInfo.isGranted;
```


## Example

See the example directory for a complete sample app.


## License

The project is under the MIT license.