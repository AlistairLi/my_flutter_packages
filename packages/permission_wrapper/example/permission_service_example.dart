import 'package:permission_wrapper/permission_wrapper.dart';

void main() async {
  // 1. 注册权限配置
  _registerPermissionConfigs();

  // 2. 添加权限状态监听
  PermissionManager.addStatusListener((permissionType, result) {
    print('权限状态变化: ${permissionType.toString()} -> ${result.toString()}');
  });

  // 3. 检查单个权限
  await _checkSinglePermission();

  // 4. 批量检查权限
  await _checkMultiplePermissions();

  // 5. 检查权限是否已授权
  await _checkPermissionStatus();

  // 6. 打开设置页面
  await _openSettings();
}

/// 注册权限配置
void _registerPermissionConfigs() {
  // 相机权限配置
  PermissionManager.registerPermissionConfig(
    PermissionType.camera,
    const PermissionConfig(
      title: '相机权限',
      description: '需要相机权限来拍摄照片和视频',
      deniedMessage: '相机权限被拒绝，无法使用拍照功能',
      permanentlyDeniedMessage: '相机权限被永久拒绝，请在设置中手动开启',
      isRequired: true,
      retryCount: 2,
    ),
  );

  // 麦克风权限配置
  PermissionManager.registerPermissionConfig(
    PermissionType.microphone,
    const PermissionConfig(
      title: '麦克风权限',
      description: '需要麦克风权限来进行语音通话',
      deniedMessage: '麦克风权限被拒绝，无法进行语音通话',
      permanentlyDeniedMessage: '麦克风权限被永久拒绝，请在设置中手动开启',
      isRequired: true,
      retryCount: 1,
    ),
  );

  // 存储权限配置
  PermissionManager.registerPermissionConfig(
    PermissionType.storage,
    const PermissionConfig(
      title: '存储权限',
      description: '需要存储权限来保存文件',
      deniedMessage: '存储权限被拒绝，无法保存文件',
      permanentlyDeniedMessage: '存储权限被永久拒绝，请在设置中手动开启',
      isRequired: false,
      retryCount: 1,
    ),
  );
}

/// 检查单个权限
Future<void> _checkSinglePermission() async {
  print('\n=== 检查单个权限 ===');

  final result = await PermissionManager.checkPermission(
    PermissionType.camera,
    hasAuthRecord: true,
    onAlert: (permissionType, result, message) async {
      print('权限弹窗回调: $message');
      // 这里可以显示自定义弹窗
    },
  );

  print('相机权限结果: ${result.result}');
  print('是否已授权: ${result.isGranted}');
  print('错误信息: ${result.message}');
}

/// 批量检查权限
Future<void> _checkMultiplePermissions() async {
  print('\n=== 批量检查权限 ===');

  final permissionTypes = [
    PermissionType.camera,
    PermissionType.microphone,
    PermissionType.storage,
  ];

  final result = await PermissionManager.checkMultiplePermissions(
    permissionTypes,
    hasAuthRecord: true,
    onAlert: (permissionType, result, message) async {
      print('批量权限弹窗回调: ${permissionType.toString()} - $message');
    },
  );

  print('所有权限是否已授权: ${result.allGranted}');
  print('被拒绝的权限数量: ${result.deniedPermissions.length}');
  print('永久拒绝的权限数量: ${result.permanentlyDeniedPermissions.length}');

  for (final permissionResult in result.results) {
    print('${permissionResult.permissionType}: ${permissionResult.result}');
  }
}

/// 检查权限状态
Future<void> _checkPermissionStatus() async {
  print('\n=== 检查权限状态 ===');

  final isCameraGranted = await PermissionManager.isPermissionGranted(
    PermissionType.camera,
    () => Future.value(33),
  );
  final isMicrophoneGranted = await PermissionManager.isPermissionGranted(
    PermissionType.microphone,
    () => Future.value(33),
  );

  print('相机权限已授权: $isCameraGranted');
  print('麦克风权限已授权: $isMicrophoneGranted');

  // 获取权限配置
  final cameraConfig =
      PermissionManager.getPermissionConfig(PermissionType.camera);
  print('相机权限标题: ${cameraConfig?.title}');
  print('相机权限描述: ${cameraConfig?.description}');

  // 获取权限说明文案
  final description =
      PermissionManager.getPermissionDescription(PermissionType.camera);
  print('相机权限说明: $description');
}

/// 打开设置页面
Future<void> _openSettings() async {
  print('\n=== 打开设置页面 ===');

  // 检查是否有权限被永久拒绝
  final history = PermissionManager.getPermissionHistory();
  final permanentlyDenied = history.entries
      .where((entry) => entry.value == PermissionResult.permanentlyDenied)
      .map((entry) => entry.key)
      .toList();

  if (permanentlyDenied.isNotEmpty) {
    print(
        '发现永久拒绝的权限: ${permanentlyDenied.map((p) => p.toString()).join(', ')}');

    // 打开应用设置页面
    final opened = await PermissionManager.openAppSettings();
    print('设置页面是否打开: $opened');
  }
}
