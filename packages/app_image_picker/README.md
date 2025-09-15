# app_image_picker

A Flutter package that provides a simplified and unified interface for picking images from gallery or camera, built on top of image_picker plugin.


## Features

- Pick images from gallery
- Capture photos with camera
- File metadata extraction (mime type, file size, name)
- Permission handling callback
- Unified interface for image picking


## Installation
Add the dependency in `pubspec.yaml`:

```yaml 
dependencies:
  app_image_picker: ^1.0.0
```

Then run:
``` bash
flutter pub get
```


## Usage

```dart
import 'package:app_image_picker/app_image_picker.dart';

void main() {
  _takePhoto();
  _choosePhoto();
}

/// 拍照
Future<String?> _takePhoto() async {
  var info = await AppImagePickerFactory.instance.pickFromCamera(
    onPermissionRequest: () async {
      // 调用方实现权限请求
      return true;
    },
  );
  return info?.path;
}

/// 选择图片
Future<String?> _choosePhoto() async {
  var info = await AppImagePickerFactory.instance.pickFromGallery(
    onPermissionRequest: () async {
      // 调用方实现权限请求
      return true;
    },
  );
  return info?.path;
}
```


## Example

See the example directory for a complete sample app.


## License

The project is under the MIT license.