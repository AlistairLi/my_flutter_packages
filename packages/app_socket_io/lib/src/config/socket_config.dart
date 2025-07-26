/// Socket 配置类
class SocketConfig {
  /// 获取登录状态
  final Future<bool> Function() isLoggedIn;

  /// 获取Token
  final Future<String?> Function() token;

  /// 获取请求头
  final Future<Map<String, dynamic>> Function() headers;

  final String version;
  final String socketPath;
  final List<String>? transports;

  /// 重连间隔（毫秒）
  final int reconnectInterval;

  /// 最大重连次数
  final int maxReconnectAttempts;

  /// 是否启用自动重连
  final bool enableAutoReconnect;

  /// 是否启用日志
  final bool enableLogging;

  SocketConfig({
    required this.isLoggedIn,
    required this.token,
    required this.headers,
    required this.version,
    required this.socketPath,
    this.transports,
    this.reconnectInterval = 5000,
    this.maxReconnectAttempts = 5,
    this.enableAutoReconnect = true,
    this.enableLogging = true,
  });

  /// 创建默认配置
  factory SocketConfig.defaultConfig({
    required Future<bool> Function() isLoggedIn,
    required Future<String?> Function() token,
    required Future<Map<String, dynamic>> Function() headers,
    required String version,
    required String socketPath,
  }) {
    return SocketConfig(
      isLoggedIn: isLoggedIn,
      token: token,
      headers: headers,
      version: version,
      socketPath: socketPath,
    );
  }

  /// 复制并修改配置
  SocketConfig copyWith({
    Future<bool> Function()? isLoggedIn,
    Future<String?> Function()? token,
    Future<Map<String, dynamic>> Function()? headers,
    String? version,
    String? socketPath,
    List<String>? transports,
    int? connectTimeout,
    int? reconnectInterval,
    int? maxReconnectAttempts,
    bool? enableAutoReconnect,
    bool? enableLogging,
  }) {
    return SocketConfig(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      token: token ?? this.token,
      headers: headers ?? this.headers,
      version: version ?? this.version,
      socketPath: socketPath ?? this.socketPath,
      transports: transports ?? this.transports,
      reconnectInterval: reconnectInterval ?? this.reconnectInterval,
      maxReconnectAttempts: maxReconnectAttempts ?? this.maxReconnectAttempts,
      enableAutoReconnect: enableAutoReconnect ?? this.enableAutoReconnect,
      enableLogging: enableLogging ?? this.enableLogging,
    );
  }
}

/// 全局Socket配置管理器
class GlobalSocketConfig {
  GlobalSocketConfig._();

  static SocketConfig? _globalConfig;

  /// 设置全局配置
  static void setGlobalConfig(SocketConfig config) {
    _globalConfig = config;
  }

  /// 获取全局配置
  static SocketConfig? get globalConfig => _globalConfig;

  /// 清除全局配置
  static void clearGlobalConfig() {
    _globalConfig = null;
  }

  /// 检查是否有全局配置
  static bool get hasGlobalConfig => _globalConfig != null;
}
