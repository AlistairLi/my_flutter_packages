abstract class FacebookConfigInterface {
  /// 获取默认的Facebook ID
  String get defaultId;

  /// 获取默认的Facebook Token
  String get defaultToken;

  /// 获取服务器下发的Facebook  ID
  Future<String?> get serverId;

  /// 获取服务器下发的Facebook  Token
  Future<String?> get serverToken;
}
