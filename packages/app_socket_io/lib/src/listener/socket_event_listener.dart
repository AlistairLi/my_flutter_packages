/// Socket事件监听器接口
abstract class SocketEventListener {
  /// 连接成功
  void onConnected(Object? data);

  /// 连接中
  void onConnecting(Object? data);

  /// 连接断开
  void onDisconnected(Object? data);

  /// 连接错误
  void onConnectError(Object? data);

  /// 连接超时
  void onConnectTimeout(Object? data);

  /// 错误
  void onError(Object? data);

  /// 收到消息
  void onMessage(String event, Object? data);

  /// 业务逻辑重连尝试
  void onBizReconnectAttempt(int attempt, int maxAttempts);

  /// 业务逻辑重连失败
  void onBizReconnectFailed();

  /// 重连
  void onReconnect(Object? data);

  /// 重连失败
  void onReconnectFailed(Object? data);

  /// 重连错误
  void onReconnectError(Object? data);
}

/// 默认Socket事件监听器实现
class DefaultSocketEventListener implements SocketEventListener {
  @override
  void onConnected(Object? data) {
    // 默认实现为空，子类可以重写
  }

  @override
  void onConnecting(Object? data) {
    // 默认实现为空，子类可以重写
  }

  @override
  void onDisconnected(Object? data) {
    // 默认实现为空，子类可以重写
  }

  @override
  void onConnectError(Object? data) {
    // TODO: implement onConnectError
  }

  @override
  void onConnectTimeout(Object? data) {
    // 默认实现为空，子类可以重写
  }

  @override
  void onError(Object? data) {
    // 默认实现为空，子类可以重写
  }

  @override
  void onMessage(String event, Object? data) {
    // 默认实现为空，子类可以重写
  }

  @override
  void onBizReconnectAttempt(int attempt, int maxAttempts) {
    // 默认实现为空，子类可以重写
  }

  @override
  void onBizReconnectFailed() {
    // 默认实现为空，子类可以重写
  }

  @override
  void onReconnect(Object? data) {
    // 默认实现为空，子类可以重写
  }

  @override
  void onReconnectFailed(Object? data) {
    // 默认实现为空，子类可以重写
  }

  @override
  void onReconnectError(Object? data) {
    // 默认实现为空，子类可以重写
  }
}

/// Socket事件监听器管理器
class SocketEventListenerManager {
  final List<SocketEventListener> _listeners = [];

  /// 添加监听器
  void addListener(SocketEventListener listener) {
    if (!_listeners.contains(listener)) {
      _listeners.add(listener);
    }
  }

  /// 移除监听器
  void removeListener(SocketEventListener listener) {
    _listeners.remove(listener);
  }

  /// 清除所有监听器
  void clearListeners() {
    _listeners.clear();
  }

  /// 通知连接成功
  void notifyConnected(Object? data) {
    for (final listener in _listeners) {
      listener.onConnected(data);
    }
  }

  /// 通知连接中
  void notifyConnecting(Object? data) {
    for (final listener in _listeners) {
      listener.onConnecting(data);
    }
  }

  /// 通知连接断开
  void notifyDisconnected(Object? data) {
    for (final listener in _listeners) {
      listener.onDisconnected(data);
    }
  }

  /// 通知连接错误
  void notifyConnectError(Object? data) {
    for (final listener in _listeners) {
      listener.onConnectError(data);
    }
  }

  /// 通知连接超时
  void notifyConnectTimeout(Object? data) {
    for (final listener in _listeners) {
      listener.onConnectTimeout(data);
    }
  }

  /// 通知错误
  void notifyError(Object? data) {
    for (final listener in _listeners) {
      listener.onError(data);
    }
  }

  /// 通知收到消息
  void notifyMessage(String event, Object? data) {
    for (final listener in _listeners) {
      listener.onMessage(event, data);
    }
  }

  /// 通知业务逻辑的重连尝试
  void notifyBizReconnectAttempt(int attempt, int maxAttempts) {
    for (final listener in _listeners) {
      listener.onBizReconnectAttempt(attempt, maxAttempts);
    }
  }

  /// 通知业务逻辑的重连失败
  void notifyBizReconnectFailed() {
    for (final listener in _listeners) {
      listener.onBizReconnectFailed();
    }
  }

  /// 通知重连
  void notifyReconnect(Object? data) {
    for (final listener in _listeners) {
      listener.onReconnect(data);
    }
  }

  /// 通知重连失败
  void notifyReconnectFailed(Object? data) {
    for (final listener in _listeners) {
      listener.onReconnectFailed(data);
    }
  }

  /// 通知重连错误
  void notifyReconnectError(Object? data) {
    for (final listener in _listeners) {
      listener.onReconnectError(data);
    }
  }
}
