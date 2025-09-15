# ali_oss_upload

A Flutter package for uploading files to Aliyun Object Storage Service (OSS) with authentication and configuration support.

There is a more comprehensive library, `flutter_oss_aliyun`


## Features

- Simple Aliyun OSS file upload
- Authentication support
- Customizable upload configuration
- Automatic filename generation
- Upload result parsing


## Installation
Add the dependency in `pubspec.yaml`:

```yaml 
dependencies:
  ali_oss_upload: ^0.0.1
```

Then run:
``` bash
flutter pub get
```


## Usage

```dart
import 'package:ali_oss_upload/app_oss_upload.dart';

void main() async {
  var localPath = 'xxx/xxx/image.png';

  // 从项目的服务器获取OSS凭证信息
  Map<String, dynamic>? ossAuthMap;
  ossAuthMap = await Future.delayed(Duration(milliseconds: 500));
  if (ossAuthMap == null || ossAuthMap.isEmpty) return null;
  var ossAuth = OssAuth.fromJson(ossAuthMap);

  // 上传文件到oss
  OssResult? ossResult = await OssUploadService.uploadFile(
    filePath: localPath,
    ossAuth: ossAuth,
  );
  if (ossResult == null) return null;

  // 上传文件的OSS路径到项目的服务器
  // ossResult.filename
}

```


## Example

See the example directory for a complete sample app.


## License

The project is under the MIT license.