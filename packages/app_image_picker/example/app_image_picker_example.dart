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
