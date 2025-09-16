abstract class AJStorageInterface {
  /// 保存数据到本地
  Future<bool> saveString(String key, String value);

  /// 从本地获取数据
  Future<String?> getString(String key);

  /// 删除本地数据
  Future<bool> remove(String key);
}
