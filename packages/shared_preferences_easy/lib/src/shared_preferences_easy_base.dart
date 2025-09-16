import 'package:shared_preferences/shared_preferences.dart';

class PreferenceUtils {
  PreferenceUtils._();

  static late SharedPreferences _prefs;
  static bool _isInit = false;

  /// 初始化
  static Future<void> init() async {
    if (!_isInit) {
      _prefs = await SharedPreferences.getInstance();
      _isInit = true;
    }
  }

  /// 获取 SharedPreferences 实例（用于复杂操作）
  static SharedPreferences get raw => _prefs;

  static bool _checkInitial() {
    if (!_isInit) {
      throw Exception('SharedPreferences not initialized');
    }
    return true;
  }

  /// 存储数据
  static Future<bool> set(String key, dynamic value) {
    if (!_checkInitial()) {
      return Future.value(false);
    }
    if (value == null) {
      return _prefs.remove(key);
    } else if (value is String) {
      return _prefs.setString(key, value);
    } else if (value is int) {
      return _prefs.setInt(key, value);
    } else if (value is double) {
      return _prefs.setDouble(key, value);
    } else if (value is bool) {
      return _prefs.setBool(key, value);
    } else if (value is List<String>) {
      return _prefs.setStringList(key, value);
    } else {
      throw UnsupportedError('Unsupported value type: ${value.runtimeType}');
    }
  }

  /// 读取数据
  static T? get<T>(String key, {T? defaultValue}) {
    final dynamic value = _prefs.get(key);

    if (value == null) {
      return defaultValue;
    }

    if (T == String) {
      return value as T?;
    } else if (T == int) {
      if (value is int) {
        return value as T?;
      } else if (value is String) {
        final parsed = int.tryParse(value);
        return parsed as T?;
      }
    } else if (T == double) {
      if (value is double) {
        return value as T?;
      } else if (value is String) {
        final parsed = double.tryParse(value);
        return parsed as T?;
      }
    } else if (T == bool) {
      return value as T?;
    } else if (T == List<String>) {
      if (value is List<String>) {
        return value as T?;
      } else if (value is List) {
        return value.cast<String>() as T?;
      }
    }
    // else {
    //   throw UnsupportedError('Unsupported type: $T');
    // }
    return null;
  }

  /// 删除某个键
  static Future<bool> remove(String key) {
    return _prefs.remove(key);
  }

  /// 清空所有数据
  static Future<bool> clear() {
    return _prefs.clear();
  }

  /// 获取所有键
  Set<String> getKeys() {
    return _prefs.getKeys();
  }
}
