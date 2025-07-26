import 'package:app_socket_io/src/app_socket_core.dart';
import 'package:app_socket_io/src/listener/socket_event_listener.dart';
import 'package:app_socket_io/src/socket_status.dart';

import 'config/socket_config.dart';

/// Socket 连接管理
class AppSocketManager {
  AppSocketManager._internal();

  static final AppSocketManager _instance = AppSocketManager._internal();

  factory AppSocketManager() {
    return _instance;
  }

  AppSocketCore? _appSocketCore;

  /// 连接socket
  /// 登录成功进入首页后调用
  /// 如果不传config参数，将使用全局配置
  Future<void> connect([SocketConfig? config]) async {
    if (_appSocketCore != null) {
      dispose();
      await Future.delayed(Duration(milliseconds: 500));
    }
    _appSocketCore = AppSocketCore();
    _appSocketCore?.connect(config);
  }

  /// 断开 socket
  /// 退出登录时调用
  void disconnect() {
    _appSocketCore?.disconnect();
    _appSocketCore = null;
  }

  /// 检查没连接到会去重新连接。
  void checkStatus() {
    _appSocketCore?.checkConnectStatus();
  }

  /// 发送事件
  Future<bool> sendEvent(
    String event,
    Map<String, dynamic> data,
  ) async {
    return await _appSocketCore?.sendEvent(event, data) ?? false;
  }

  /// 添加事件监听器
  void addEventListener(SocketEventListener listener) {
    _appSocketCore?.addEventListener(listener);
  }

  /// 移除事件监听器
  void removeEventListener(SocketEventListener listener) {
    _appSocketCore?.removeEventListener(listener);
  }

  /// 获取连接状态
  SocketStatus? get connectStatus => _appSocketCore?.connectStatus;

  /// 是否已连接
  bool get isConnected => _appSocketCore?.isConnected ?? false;

  /// 是否正在连接
  bool get isConnecting => _appSocketCore?.isConnecting ?? false;

  /// 是否正在重连
  bool get isReconnecting => _appSocketCore?.isReconnecting ?? false;

  /// 获取队列中的消息数量
  int get queuedMessageCount => _appSocketCore?.queuedMessageCount ?? 0;

  /// 清空消息队列
  void clearMessageQueue() {
    _appSocketCore?.clearMessageQueue();
  }

  /// 释放资源
  void dispose() {
    _appSocketCore?.dispose();
    _appSocketCore = null;
  }
}
