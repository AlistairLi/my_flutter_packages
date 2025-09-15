/// 图片信息结构
class PickedImageInfo {
  final String path;
  final int? width;
  final int? height;
  final String? mimeType;
  final String? name;
  final int? length;

  PickedImageInfo({
    required this.path,
    this.width,
    this.height,
    this.mimeType,
    this.name,
    this.length,
  });
}

/// 权限请求回调类型
typedef PermissionRequestCallback = Future<bool> Function();

/// 图片选择抽象接口
abstract class AppImagePicker {
  /// 从图库选择图片
  Future<PickedImageInfo?> pickFromGallery(
      {PermissionRequestCallback? onPermissionRequest});

  /// 拍照获取图片
  Future<PickedImageInfo?> pickFromCamera(
      {PermissionRequestCallback? onPermissionRequest});
}
