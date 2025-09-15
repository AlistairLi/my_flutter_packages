import 'dart:ui' as ui;

import 'package:image_picker/image_picker.dart';

import 'app_image_picker_base.dart';

/// image_picker 实现
class ImagePickerImpl implements AppImagePicker {
  final ImagePicker _picker = ImagePicker();

  @override
  Future<PickedImageInfo?> pickFromGallery(
      {PermissionRequestCallback? onPermissionRequest}) async {
    if (onPermissionRequest != null) {
      final granted = await onPermissionRequest();
      if (!granted) return null;
    }
    return _pickImage(source: ImageSource.gallery);
  }

  @override
  Future<PickedImageInfo?> pickFromCamera(
      {PermissionRequestCallback? onPermissionRequest}) async {
    if (onPermissionRequest != null) {
      final granted = await onPermissionRequest();
      if (!granted) return null;
    }
    return _pickImage(source: ImageSource.camera);
  }

  Future<PickedImageInfo?> _pickImage({required ImageSource source}) async {
    final XFile? file = await _picker.pickImage(source: source);
    if (file == null) return null;
    int? width;
    int? height;
    try {
      final bytes = await file.readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      width = frame.image.width;
      height = frame.image.height;
    } catch (_) {}
    return PickedImageInfo(
      path: file.path,
      length: await file.length(),
      width: width,
      height: height,
      mimeType: file.mimeType,
      name: file.name,
    );
  }
}
