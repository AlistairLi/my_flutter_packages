import 'package:permission_wrapper/permission_wrapper.dart';
import 'package:test/test.dart';

void main() {
  group('PermissionManager Tests', () {
    setUp(() {
      // 清除之前的配置和历史记录
      PermissionManager.clearPermissionHistory();
    });

    test('should register permission config', () {
      const config = PermissionConfig(
        title: '测试权限',
        description: '测试权限描述',
        deniedMessage: '权限被拒绝',
        permanentlyDeniedMessage: '权限被永久拒绝',
      );

      PermissionManager.registerPermissionConfig(PermissionType.camera, config);

      final retrievedConfig =
          PermissionManager.getPermissionConfig(PermissionType.camera);
      expect(retrievedConfig, equals(config));
    });

    test('should get permission title', () {
      const config = PermissionConfig(
        title: '相机权限',
        description: '相机权限描述',
        deniedMessage: '权限被拒绝',
        permanentlyDeniedMessage: '权限被永久拒绝',
      );

      PermissionManager.registerPermissionConfig(PermissionType.camera, config);

      final title = PermissionManager.getPermissionTitle(PermissionType.camera);
      expect(title, equals('相机权限'));
    });

    test('should get permission description', () {
      const config = PermissionConfig(
        title: '相机权限',
        description: '相机权限描述',
        deniedMessage: '权限被拒绝',
        permanentlyDeniedMessage: '权限被永久拒绝',
      );

      PermissionManager.registerPermissionConfig(PermissionType.camera, config);

      final description =
          PermissionManager.getPermissionDescription(PermissionType.camera);
      expect(description, equals('相机权限描述'));
    });

    test('should check if permission is required', () {
      const config = PermissionConfig(
        title: '相机权限',
        description: '相机权限描述',
        deniedMessage: '权限被拒绝',
        permanentlyDeniedMessage: '权限被永久拒绝',
        isRequired: false,
      );

      PermissionManager.registerPermissionConfig(PermissionType.camera, config);

      final isRequired =
          PermissionManager.isRequiredPermission(PermissionType.camera);
      expect(isRequired, equals(false));
    });

    test('should return default values for unregistered permissions', () {
      final title =
          PermissionManager.getPermissionTitle(PermissionType.microphone);
      expect(title, equals('权限请求'));

      final description =
          PermissionManager.getPermissionDescription(PermissionType.microphone);
      expect(description, equals('需要此权限才能正常使用相关功能'));

      final isRequired =
          PermissionManager.isRequiredPermission(PermissionType.microphone);
      expect(isRequired, equals(true));
    });

    test('should manage permission history', () {
      final history = PermissionManager.getPermissionHistory();
      expect(history, isEmpty);

      // 模拟权限历史记录
      PermissionManager.clearPermissionHistory();
      expect(PermissionManager.getPermissionHistory(), isEmpty);
    });

    test('should handle status listeners', () {
      bool listenerCalled = false;
      PermissionType? calledPermissionType;
      PermissionResult? calledResult;

      final callback =
          (PermissionType permissionType, PermissionResult result) {
        listenerCalled = true;
        calledPermissionType = permissionType;
        calledResult = result;
      };

      PermissionManager.addStatusListener(callback);

      // 这里可以添加更多测试，但需要模拟权限状态变化

      PermissionManager.removeStatusListener(callback);
    });

    test('should create PermissionResultInfo correctly', () {
      const resultInfo = PermissionResultInfo(
        permissionType: PermissionType.camera,
        result: PermissionResult.granted,
        message: '权限已授权',
        isGranted: true,
      );

      expect(resultInfo.permissionType, equals(PermissionType.camera));
      expect(resultInfo.result, equals(PermissionResult.granted));
      expect(resultInfo.message, equals('权限已授权'));
      expect(resultInfo.isGranted, equals(true));
    });

    test('should create BatchPermissionResult correctly', () {
      const resultInfo1 = PermissionResultInfo(
        permissionType: PermissionType.camera,
        result: PermissionResult.granted,
        isGranted: true,
      );

      const resultInfo2 = PermissionResultInfo(
        permissionType: PermissionType.microphone,
        result: PermissionResult.denied,
        isGranted: false,
      );

      const batchResult = BatchPermissionResult(
        results: [resultInfo1, resultInfo2],
        allGranted: false,
        deniedPermissions: [resultInfo2],
        permanentlyDeniedPermissions: [],
      );

      expect(batchResult.results, hasLength(2));
      expect(batchResult.allGranted, equals(false));
      expect(batchResult.deniedPermissions, hasLength(1));
      expect(batchResult.permanentlyDeniedPermissions, isEmpty);
    });
  });
}
