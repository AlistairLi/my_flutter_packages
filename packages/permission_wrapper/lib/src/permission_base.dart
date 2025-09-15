/// 权限状态枚举
enum PermissionResult {
  granted, // 已授权
  denied, // 被拒绝
  permanentlyDenied, // 永久拒绝
  limited, // 有限授权
  restricted, // 受限制
  unavailable, // 不可用
}

/// 权限类型枚举
enum PermissionType {
  camera, // 相机
  microphone, // 麦克风
  photos, // 相册
  videos, // 视频
  audio, // 音频
  storage, // 存储
  location, // 位置
  contacts, // 通讯录
  phone, // 电话
  calendarWriteOnly, // 日历
  calendarFullAccess, // 日历
  notification, // 通知
  bluetooth, // 蓝牙
  custom, // 自定义
}

/// 权限配置
class PermissionConfig {
  final String title; // 权限标题
  final String description; // 权限描述
  final String deniedMessage; // 拒绝时的提示信息
  final String permanentlyDeniedMessage; // 永久拒绝时的提示信息
  final bool isRequired; // 是否必需权限
  final int retryCount; // 重试次数

  const PermissionConfig({
    required this.title,
    required this.description,
    required this.deniedMessage,
    required this.permanentlyDeniedMessage,
    this.isRequired = true,
    this.retryCount = 1,
  });
}

/// 权限结果
class PermissionResultInfo {
  final PermissionType permissionType;
  final PermissionResult result;
  final String? message;
  final bool isGranted;

  const PermissionResultInfo({
    required this.permissionType,
    required this.result,
    this.message,
    required this.isGranted,
  });
}

/// 批量权限结果
class BatchPermissionResult {
  final List<PermissionResultInfo> results;
  final bool allGranted;
  final List<PermissionResultInfo> deniedPermissions;
  final List<PermissionResultInfo> permanentlyDeniedPermissions;

  const BatchPermissionResult({
    required this.results,
    required this.allGranted,
    required this.deniedPermissions,
    required this.permanentlyDeniedPermissions,
  });
}

/// 弹窗/提示回调
typedef PermissionAlertCallback = Future<void> Function(
    PermissionType permissionType, PermissionResult result, String message);

/// 权限状态变化回调
typedef PermissionStatusCallback = void Function(
    PermissionType permissionType, PermissionResult result);

/// SDK版本获取回调
typedef SdkIntProvider = Future<int?> Function();
