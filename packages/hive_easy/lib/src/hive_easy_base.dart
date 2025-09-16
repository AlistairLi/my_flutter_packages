import 'dart:convert';

import 'package:hive_ce_flutter/hive_flutter.dart';

/// 数据存储级别
enum StorageLevel {
  /// 应用级别 - 与用户无关的数据
  app,

  /// 用户级别 - 与当前登录用户绑定的数据
  user,
}

/// Hive 工具类
/// 提供 Hive 数据库的基本操作
/// 支持应用级别和用户级别的数据存储
class HiveUtil {
  HiveUtil._();

  static const String _appBoxName = 'app_box';
  static const String _userBoxName = 'user_box';

  static Box? _appBox;
  static Box? _userBox;
  static bool _isInitialized = false;

  /// 当前用户ID，用于用户级别数据存储
  static String? _currentUserId;

  /// 获取用户级别盒子名称
  static String _getUserBoxName(String userId) {
    final targetUserId = userId;
    return '${_userBoxName}_$targetUserId';
  }

  /// 初始化 Hive
  /// [path] 数据库文件存储路径，如果不提供则使用默认路径
  static Future<void> init({String? path}) async {
    if (_isInitialized) return;

    // 初始化 Hive
    await Hive.initFlutter(path);

    // 打开应用级别盒子
    _appBox = await Hive.openBox(_appBoxName);

    _isInitialized = true;
  }

  /// 设置当前用户ID
  /// [userId] 用户ID，如果为空或null则清除当前用户
  static Future<void> setCurrentUser(String? userId) async {
    if (!_isInitialized) {
      await init();
    }

    if (userId == null || userId.trim().isEmpty) {
      await clearCurrentUser();
      return;
    }

    final trimmedUserId = userId.trim();

    // 如果设置的是同一个用户，不需要重新打开盒子
    if (_currentUserId == trimmedUserId && _userBox != null) {
      return;
    }

    try {
      // 关闭之前的用户盒子
      if (_userBox != null) {
        await _userBox!.close();
        _userBox = null;
      }

      _currentUserId = trimmedUserId;

      // 打开新的用户盒子
      _userBox = await Hive.openBox(_getUserBoxName(trimmedUserId));
    } catch (e) {
      // 如果打开盒子失败，清除用户状态
      _currentUserId = null;
      _userBox = null;
      rethrow;
    }
  }

  /// 清除当前用户（退出登录时调用）
  static Future<void> clearCurrentUser() async {
    try {
      if (_userBox != null) {
        await _userBox!.close();
        _userBox = null;
      }
      _currentUserId = null;
    } catch (e) {
      // 即使关闭盒子失败，也要清除状态
      _userBox = null;
      _currentUserId = null;
    }
  }

  /// 删除当前用户数据（删除账号时调用）
  /// 会删除当前用户的所有数据并清除用户状态
  static Future<void> deleteCurrentUserData() async {
    try {
      if (_currentUserId == null || _currentUserId!.isEmpty) {
        return;
      }

      final userId = _currentUserId!;
      final boxName = _getUserBoxName(userId);

      // 1. 关闭用户盒子
      if (_userBox != null) {
        await _userBox!.close();
        _userBox = null;
      }

      // 2. 从磁盘删除用户盒子
      await Hive.deleteBoxFromDisk(boxName);

      // 3. 清除用户状态
      _currentUserId = null;
    } catch (e) {
      // 即使删除失败，也要清除状态
      _userBox = null;
      _currentUserId = null;
      rethrow;
    }
  }

  /// 删除指定用户的数据
  /// [userId] 要删除的用户ID
  static Future<void> deleteUserData(String userId) async {
    try {
      if (userId.isEmpty) {
        throw ArgumentError('userId cannot be empty');
      }

      final boxName = _getUserBoxName(userId);

      // 如果删除的是当前用户，先关闭盒子
      if (_currentUserId == userId && _userBox != null) {
        await _userBox!.close();
        _userBox = null;
        _currentUserId = null;
      }

      // 从磁盘删除用户盒子
      await Hive.deleteBoxFromDisk(boxName);
    } catch (e) {
      rethrow;
    }
  }

  /// 获取应用级别盒子
  static Box get appBox {
    if (_appBox == null) {
      throw Exception(
          'Hive has not been initialized. Please call HiveUtil.init() first.');
    }
    return _appBox!;
  }

  /// 获取用户级别盒子
  static Box get userBox {
    if (_userBox == null) {
      throw Exception(
          'User box has not been initialized. Please call HiveUtil.setCurrentUser() first.');
    }
    return _userBox!;
  }

  /// 根据存储级别获取对应的盒子
  static Box _getBoxByLevel(StorageLevel level) {
    switch (level) {
      case StorageLevel.app:
        return appBox;
      case StorageLevel.user:
        return userBox;
    }
  }

  /// 打开指定的盒子
  /// [boxName] 盒子名称
  static Future<Box> openBox(String boxName) async {
    if (!_isInitialized) {
      await init();
    }
    return await Hive.openBox(boxName);
  }

  /// 关闭指定的盒子
  /// [boxName] 盒子名称
  static Future<void> closeBox(String boxName) async {
    await Hive.box(boxName).close();
  }

  /// 删除指定的盒子
  /// [boxName] 盒子名称
  static Future<void> deleteBox(String boxName) async {
    await Hive.deleteBoxFromDisk(boxName);
  }

  // ==================== 应用级别数据操作 ====================

  /// 存储应用级别字符串
  static Future<void> putAppString(String key, String value) async {
    await appBox.put(key, value);
  }

  /// 获取应用级别字符串
  static String getAppString(String key, {String defaultValue = ''}) {
    return appBox.get(key, defaultValue: defaultValue) ?? defaultValue;
  }

  /// 存储应用级别整数
  static Future<void> putAppInt(String key, int value) async {
    await appBox.put(key, value);
  }

  /// 获取应用级别整数
  static int getAppInt(String key, {int defaultValue = 0}) {
    return appBox.get(key, defaultValue: defaultValue) ?? defaultValue;
  }

  /// 存储应用级别布尔值
  static Future<void> putAppBool(String key, bool value) async {
    await appBox.put(key, value);
  }

  /// 获取应用级别布尔值
  static bool getAppBool(String key, {bool defaultValue = false}) {
    return appBox.get(key, defaultValue: defaultValue) ?? defaultValue;
  }

  /// 存储应用级别对象
  static Future<void> putAppObject(
      String key, Map<String, dynamic> value) async {
    await appBox.put(key, jsonEncode(value));
  }

  /// 获取应用级别对象
  static Map<String, dynamic> getAppObject(String key,
      {Map<String, dynamic>? defaultValue}) {
    final value = appBox.get(key);
    if (value == null) return defaultValue ?? {};

    try {
      return jsonDecode(value) as Map<String, dynamic>;
    } catch (e) {
      return defaultValue ?? {};
    }
  }

  /// 存储应用级别列表
  static Future<void> putAppList(String key, List<dynamic> value) async {
    await appBox.put(key, jsonEncode(value));
  }

  /// 获取应用级别列表
  static List<dynamic> getAppList(String key, {List<dynamic>? defaultValue}) {
    final value = appBox.get(key);
    if (value == null) return defaultValue ?? [];

    try {
      return jsonDecode(value) as List<dynamic>;
    } catch (e) {
      return defaultValue ?? [];
    }
  }

  // ==================== 用户级别数据操作 ====================

  /// 存储用户级别字符串
  static Future<void> putUserString(String key, String value) async {
    await userBox.put(key, value);
  }

  /// 获取用户级别字符串
  static String getUserString(String key, {String defaultValue = ''}) {
    return userBox.get(key, defaultValue: defaultValue) ?? defaultValue;
  }

  /// 存储用户级别整数
  static Future<void> putUserInt(String key, int value) async {
    await userBox.put(key, value);
  }

  /// 获取用户级别整数
  static int getUserInt(String key, {int defaultValue = 0}) {
    return userBox.get(key, defaultValue: defaultValue) ?? defaultValue;
  }

  /// 存储用户级别布尔值
  static Future<void> putUserBool(String key, bool value) async {
    await userBox.put(key, value);
  }

  /// 获取用户级别布尔值
  static bool getUserBool(String key, {bool defaultValue = false}) {
    return userBox.get(key, defaultValue: defaultValue) ?? defaultValue;
  }

  /// 存储用户级别对象
  static Future<void> putUserObject(
      String key, Map<String, dynamic> value) async {
    await userBox.put(key, jsonEncode(value));
  }

  /// 获取用户级别对象
  static Map<String, dynamic> getUserObject(String key,
      {Map<String, dynamic>? defaultValue}) {
    final value = userBox.get(key);
    if (value == null) return defaultValue ?? {};

    try {
      return jsonDecode(value) as Map<String, dynamic>;
    } catch (e) {
      return defaultValue ?? {};
    }
  }

  /// 存储用户级别列表
  static Future<void> putUserList(String key, List<dynamic> value) async {
    await userBox.put(key, jsonEncode(value));
  }

  /// 获取用户级别列表
  static List<dynamic> getUserList(String key, {List<dynamic>? defaultValue}) {
    final value = userBox.get(key);
    if (value == null) return defaultValue ?? [];

    try {
      return jsonDecode(value) as List<dynamic>;
    } catch (e) {
      return defaultValue ?? [];
    }
  }

  /// 批量设置用户级别数据
  /// [data] 要设置的数据，格式为 {key: value}
  static Future<void> putUserDataBatch(Map<String, dynamic> data) async {
    for (final entry in data.entries) {
      final key = entry.key;
      final value = entry.value;

      if (value is String) {
        await putUserString(key, value);
      } else if (value is int) {
        await putUserInt(key, value);
      } else if (value is bool) {
        await putUserBool(key, value);
      } else if (value is Map<String, dynamic>) {
        await putUserObject(key, value);
      } else if (value is List) {
        await putUserList(key, value);
      } else {
        // 对于其他类型，转换为JSON字符串存储
        await putUserString(key, value.toString());
      }
    }
  }

  /// 批量获取用户级别数据
  /// [keys] 要获取的键列表
  /// [defaultValues] 默认值映射，可选
  static Map<String, dynamic> getUserDataBatch(
    List<String> keys, {
    Map<String, dynamic>? defaultValues,
  }) {
    final result = <String, dynamic>{};
    for (final key in keys) {
      if (containsKey(key, level: StorageLevel.user)) {
        // 尝试获取数据，这里简化处理，实际使用时可能需要根据数据类型进行判断
        final value = userBox.get(key);
        result[key] = value;
      } else {
        result[key] = defaultValues?[key];
      }
    }
    return result;
  }

  // ==================== 工具方法 ====================

  /// 删除指定键的值
  /// [key] 键
  /// [level] 存储级别
  static Future<void> delete(String key,
      {StorageLevel level = StorageLevel.app}) async {
    final box = _getBoxByLevel(level);
    await box.delete(key);
  }

  /// 检查是否包含指定键
  /// [key] 键
  /// [level] 存储级别
  static bool containsKey(String key, {StorageLevel level = StorageLevel.app}) {
    final box = _getBoxByLevel(level);
    return box.containsKey(key);
  }

  /// 获取所有键
  /// [level] 存储级别
  static List<dynamic> getKeys({StorageLevel level = StorageLevel.app}) {
    final box = _getBoxByLevel(level);
    return box.keys.toList();
  }

  /// 获取所有值
  /// [level] 存储级别
  static List<dynamic> getValues({StorageLevel level = StorageLevel.app}) {
    final box = _getBoxByLevel(level);
    return box.values.toList();
  }

  /// 清空指定级别的所有数据
  /// [level] 存储级别
  static Future<void> clear({StorageLevel level = StorageLevel.app}) async {
    final box = _getBoxByLevel(level);
    await box.clear();
  }

  /// 获取指定级别盒子的大小
  /// [level] 存储级别
  static int getLength({StorageLevel level = StorageLevel.app}) {
    final box = _getBoxByLevel(level);
    return box.length;
  }

  /// 检查指定级别盒子是否为空
  /// [level] 存储级别
  static bool isEmpty({StorageLevel level = StorageLevel.app}) {
    final box = _getBoxByLevel(level);
    return box.isEmpty;
  }

  /// 检查指定级别盒子是否不为空
  /// [level] 存储级别
  static bool isNotEmpty({StorageLevel level = StorageLevel.app}) {
    final box = _getBoxByLevel(level);
    return box.isNotEmpty;
  }

  /// 关闭所有盒子
  static Future<void> closeAll() async {
    await Hive.close();
    _appBox = null;
    _userBox = null;
    _isInitialized = false;
    _currentUserId = null;
  }

  /// 获取当前用户ID
  static String? get currentUserId => _currentUserId;

  /// 检查是否已设置当前用户
  static bool get hasCurrentUser =>
      _currentUserId != null && _currentUserId!.isNotEmpty;
}
