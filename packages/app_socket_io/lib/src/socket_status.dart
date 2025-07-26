/// 连接状态
enum SocketStatus {
  /// 连接成功
  connected,

  /// 连接中
  connecting,

  /// 未连接
  unconnected,

  /// 断开连接
  disconnect,

  /// 连接错误
  error,

  /// 连接超时
  timeout,

  /// 网络不可用
  networkUnavailable,

  /// 异常情况
  unknown,
}
