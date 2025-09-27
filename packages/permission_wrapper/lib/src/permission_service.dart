import 'dart:io';

import 'package:permission_handler/permission_handler.dart' as handler;
import 'package:permission_handler/permission_handler.dart';
import 'package:permission_wrapper/src/permission_base.dart';

/// 权限管理工具
class PermissionManager {
  PermissionManager._();

  static final Map<PermissionType, PermissionConfig> _permissionConfigs = {};
  static final List<PermissionStatusCallback> _statusCallbacks = [];
  static final Map<PermissionType, PermissionResult> _permissionHistory = {};

  /// 权限类型到Permission映射
  static final Map<PermissionType, Permission> _permissionMapping = {
    PermissionType.camera: Permission.camera,
    PermissionType.microphone: Permission.microphone,
    PermissionType.photos: Permission.photos,
    PermissionType.videos: Permission.videos,
    PermissionType.audio: Permission.audio,
    PermissionType.storage: Permission.storage,
    PermissionType.location: Permission.location,
    PermissionType.contacts: Permission.contacts,
    PermissionType.phone: Permission.phone,
    PermissionType.calendarWriteOnly: Permission.calendarWriteOnly,
    PermissionType.calendarFullAccess: Permission.calendarFullAccess,
    PermissionType.notification: Permission.notification,
    PermissionType.bluetooth: Permission.bluetooth,
    PermissionType.custom: Permission.camera, // 自定义权限默认映射到相机
  };

  /// 状态转换
  static final Map<PermissionStatus, PermissionResult> _statusMap = {
    PermissionStatus.granted: PermissionResult.granted,
    PermissionStatus.denied: PermissionResult.denied,
    PermissionStatus.permanentlyDenied: PermissionResult.permanentlyDenied,
    PermissionStatus.limited: PermissionResult.limited,
    PermissionStatus.restricted: PermissionResult.restricted,
  };

  /// 注册权限配置
  static void registerPermissionConfig(
    PermissionType permissionType,
    PermissionConfig config,
  ) {
    _permissionConfigs[permissionType] = config;
  }

  /// 注册权限状态监听
  static void addStatusListener(PermissionStatusCallback callback) {
    _statusCallbacks.add(callback);
  }

  /// 移除权限状态监听
  static void removeStatusListener(PermissionStatusCallback callback) {
    _statusCallbacks.remove(callback);
  }

  /// 检查单个权限
  static Future<PermissionResultInfo> checkPermission(
    PermissionType permissionType, {
    bool showGuide = true,
    bool showToast = true,
    PermissionAlertCallback? onAlert,
    SdkIntProvider? sdkIntProvider,
    bool? hasAuthRecord,
  }) async {
    try {
      final permission = await _getPermission(permissionType, sdkIntProvider);
      if (permission == null) {
        return PermissionResultInfo(
          permissionType: permissionType,
          result: PermissionResult.unavailable,
          message: 'Unsupported permission types: $permissionType',
          isGranted: false,
        );
      }

      // 检查当前权限状态
      var status = await permission.status;
      var result = _convertStatus(status);

      if (result == PermissionResult.granted ||
          result == PermissionResult.limited) {
        _updateHistory(permissionType, result);
        _notifyStatusChange(permissionType, result);
        return PermissionResultInfo(
          permissionType: permissionType,
          result: result,
          isGranted: true,
        );
      }

      // 请求权限
      // Android 端行为:
      // 第一次请求权限时弹出系统的请求弹窗，拒绝权限，返回denied；
      // 第二次请求权限时仍然会弹出系统的请求弹窗，拒绝权限，返回permanentlyDenied；
      // 后续再请求权限时，不再弹出系统的请求弹窗，直接返回permanentlyDenied。
      status = await permission.request();
      result = _convertStatus(status);

      if (result == PermissionResult.granted ||
          result == PermissionResult.limited) {
        _updateHistory(permissionType, result);
        _notifyStatusChange(permissionType, result);
        return PermissionResultInfo(
          permissionType: permissionType,
          result: result,
          isGranted: true,
        );
      }

      return _handlePermissionDenied(
        permissionType,
        result,
        onAlert,
        hasAuthRecord,
      );
    } catch (e) {
      return PermissionResultInfo(
        permissionType: permissionType,
        result: PermissionResult.unavailable,
        message: 'Abnormal permission check: $e',
        isGranted: false,
      );
    }
  }

  /// 批量检查权限
  static Future<BatchPermissionResult> checkMultiplePermissions(
    List<PermissionType> permissionTypes, {
    bool showGuide = true,
    bool showToast = true,
    PermissionAlertCallback? onAlert,
    SdkIntProvider? sdkIntProvider,
    bool? hasAuthRecord,
  }) async {
    final results = <PermissionResultInfo>[];

    for (final permissionType in permissionTypes) {
      final result = await checkPermission(
        permissionType,
        showGuide: showGuide,
        showToast: showToast,
        onAlert: onAlert,
        sdkIntProvider: sdkIntProvider,
        hasAuthRecord: hasAuthRecord,
      );
      results.add(result);
    }

    final deniedPermissions = results
        .where((r) =>
            !r.isGranted && r.result != PermissionResult.permanentlyDenied)
        .toList();
    final permanentlyDeniedPermissions = results
        .where((r) => r.result == PermissionResult.permanentlyDenied)
        .toList();
    final allGranted = results.every((r) => r.isGranted);

    return BatchPermissionResult(
      results: results,
      allGranted: allGranted,
      deniedPermissions: deniedPermissions,
      permanentlyDeniedPermissions: permanentlyDeniedPermissions,
    );
  }

  /// 检查权限是否已授权
  static Future<bool> isPermissionGranted(
    PermissionType permissionType,
    SdkIntProvider? sdkIntProvider,
  ) async {
    final permission = await _getPermission(permissionType, sdkIntProvider);
    if (permission == null) return false;

    final status = await permission.status;
    return status == PermissionStatus.granted ||
        status == PermissionStatus.limited;
  }

  /// 获取权限配置
  static PermissionConfig? getPermissionConfig(PermissionType permissionType) {
    return _permissionConfigs[permissionType];
  }

  /// 打开应用设置页面
  static Future<bool> openAppSettings() async {
    return await handler.openAppSettings();
  }

  /// 获取权限历史记录
  static Map<PermissionType, PermissionResult> getPermissionHistory() {
    return Map.unmodifiable(_permissionHistory);
  }

  /// 清除权限历史记录
  static void clearPermissionHistory() {
    _permissionHistory.clear();
  }

  /// 检查是否为必需权限
  static bool isRequiredPermission(PermissionType permissionType) {
    final config = _permissionConfigs[permissionType];
    return config?.isRequired ?? true;
  }

  /// 获取权限说明文案
  static String getPermissionDescription(PermissionType permissionType) {
    final config = _permissionConfigs[permissionType];
    return config?.description ??
        'This permission is required to use the relevant functions normally';
  }

  /// 获取权限标题
  static String getPermissionTitle(PermissionType permissionType) {
    final config = _permissionConfigs[permissionType];
    return config?.title ?? 'Permission request';
  }

  /// 处理权限被拒绝的情况
  static Future<PermissionResultInfo> _handlePermissionDenied(
    PermissionType permissionType,
    PermissionResult result,
    PermissionAlertCallback? onAlert,
    bool? hasAuthRecord,
  ) async {
    final config = _permissionConfigs[permissionType];
    String message = '';

    switch (result) {
      case PermissionResult.denied:
        message = config?.deniedMessage ??
            'Permission has been denied. Please re-authorize';
        break;
      case PermissionResult.permanentlyDenied:
        message = config?.permanentlyDeniedMessage ??
            'The permission has been permanently denied. Please manually enable it in the Settings';
        break;
      case PermissionResult.restricted:
        message = 'The permission is restricted and cannot be used';
        break;
      default:
        message = 'The permission is unavailable';
    }

    // 调用外部回调
    if (onAlert != null) {
      await onAlert(permissionType, result, message);
    }

    _updateHistory(permissionType, result);
    _notifyStatusChange(permissionType, result);

    return PermissionResultInfo(
      permissionType: permissionType,
      result: result,
      message: message,
      isGranted: false,
    );
  }

  /// 转换权限状态
  static PermissionResult _convertStatus(PermissionStatus status) {
    return _statusMap[status] ?? PermissionResult.unavailable;
  }

  /// 获取Permission对象
  static Future<Permission?> _getPermission(
    PermissionType permissionType,
    SdkIntProvider? sdkIntProvider,
  ) async {
    if (Platform.isAndroid) {
      if (permissionType == PermissionType.photos) {
        assert(sdkIntProvider != null,
            '[permission_wrapper]  Please provide sdkIntProvider');
        var sdk = await sdkIntProvider?.call();
        if (sdk != null && sdk < 33) {
          return Permission.storage;
        } else {
          return Permission.photos;
        }
      }
    }
    return _permissionMapping[permissionType];
  }

  /// 更新权限历史
  static void _updateHistory(
      PermissionType permissionType, PermissionResult result) {
    _permissionHistory[permissionType] = result;
  }

  /// 通知状态变化
  static void _notifyStatusChange(
      PermissionType permissionType, PermissionResult result) {
    for (final callback in _statusCallbacks) {
      callback(permissionType, result);
    }
  }
}
