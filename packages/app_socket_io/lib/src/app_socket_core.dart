import 'dart:async';

import 'package:app_socket_io/src/listener/socket_event_listener.dart';
import 'package:app_socket_io/src/socket_status.dart';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as client;

import 'config/socket_config.dart';

class AppSocketCore {
  /// 默认支持的传输方式
  final defaultTransports = <String>['websocket'];

  client.Socket? _coreSocket;

  /// 重连计数
  int _retryCount = 0;

  /// 当前连接状态
  SocketStatus _connectStatus = SocketStatus.unconnected;

  /// 连接配置
  SocketConfig? _config;

  /// 事件监听器管理器
  final SocketEventListenerManager _eventManager = SocketEventListenerManager();

  /// 重连定时器
  Timer? _reconnectTimer;

  /// 消息队列（离线时缓存发送的消息）
  final List<Map<String, dynamic>> _messageQueue = [];

  /// 是否正在重连
  bool _isReconnecting = false;

  SocketStatus get connectStatus => _connectStatus;

  /// 获取事件监听器管理器
  SocketEventListenerManager get eventManager => _eventManager;

  /// 是否已连接
  bool get isConnected => _connectStatus == SocketStatus.connected;

  /// 是否正在连接
  bool get isConnecting => _connectStatus == SocketStatus.connecting;

  /// 是否正在重连
  bool get isReconnecting => _isReconnecting;

  /// 创建socket并连接
  Future<void> connect([SocketConfig? config]) async {
    // 使用传入的配置或全局配置
    _config = config ?? GlobalSocketConfig.globalConfig;

    if (_config == null) {
      throw Exception(
          'SocketConfig is required. Please set global config or pass config parameter.');
    }

    // 如果已经连接，先断开
    if (_coreSocket != null) {
      disconnect();
      await Future.delayed(Duration(milliseconds: 500));
    }

    _setupConnection();
  }

  /// 设置连接
  void _setupConnection() async {
    try {
      // 动态获取登录token
      String? token = await _config!.token.call();
      if (token == null || token.isEmpty) {
        _eventManager.notifyError({'error': "token is empty"});
        return;
      }

      // 动态获取请求头
      var socketHeaders = await _config!.headers.call();

      // 创建选项构建器
      var optionBuilder = client.OptionBuilder()
          .enableForceNew()
          .enableAutoConnect()
          .enableReconnection()
          .setTransports(_config!.transports ?? defaultTransports)
          .setExtraHeaders(socketHeaders)
          .setQuery({'token': token, 'ver': _config!.version});

      // 构建连接选项
      Map<String, dynamic> ops = optionBuilder.build();

      // 动态获取连接地址
      var socketPath = _config!.socketPath;
      Uri socketUri = Uri.parse(socketPath);

      // 构建完整URL
      Map<String, String> params = <String, String>{};
      params.addAll(socketUri.queryParameters);
      params.addAll({'token': token, 'ver': _config!.version});

      Uri uri = socketUri.replace(queryParameters: params);
      var link = uri.toString();

      // 创建Socket连接
      _coreSocket = client.io(link, ops);
      _observe();
    } catch (e) {
      _connectStatus = SocketStatus.error;
      _eventManager.notifyError({'error': e.toString()});
    }
  }

  /// 断开连接
  void disconnect() {
    _stopReconnectTimer();
    _messageQueue.clear();
    _isReconnecting = false;
    _retryCount = 0;

    _coreSocket?.dispose();
    _coreSocket = null;
    _connectStatus = SocketStatus.unconnected;
  }

  /// 检查状态，断开重新连接
  void checkConnectStatus({bool shouldRetry = false}) async {
    // 已连接，不处理
    if (_connected()) return;

    // 连接中，不处理
    if (_connectStatus == SocketStatus.connecting) return;

    // 未登录，不处理
    if (!((await _config?.isLoggedIn.call()) == true)) return;

    // 如果禁用自动重连，不处理
    if (!(_config?.enableAutoReconnect ?? true)) return;

    if (shouldRetry) {
      _retryCount++;

      _eventManager.notifyReconnectAttempt(
          _retryCount, _config?.maxReconnectAttempts ?? 5);

      if (_retryCount <= (_config?.maxReconnectAttempts ?? 5)) {
        _isReconnecting = true;
        _coreSocket?.connect();

        // 设置重连定时器
        _startReconnectTimer();
      } else {
        _isReconnecting = false;
        _eventManager.notifyReconnectFailed();
      }
    } else {
      _coreSocket?.connect(); // 发起连接
    }
  }

  /// 开始重连定时器
  void _startReconnectTimer() {
    _stopReconnectTimer();
    _reconnectTimer =
        Timer(Duration(milliseconds: _config?.reconnectInterval ?? 5000), () {
      if (_isReconnecting && !_connected()) {
        checkConnectStatus(shouldRetry: true);
      }
    });
  }

  /// 停止重连定时器
  void _stopReconnectTimer() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }

  /// 是否已连接
  bool _connected() {
    return _coreSocket?.connected ?? false;
  }

  /// 发送事件
  Future<bool> sendEvent(String event, Map<String, dynamic> data) async {
    try {
      if (!_connected()) {
        // 如果未连接，将消息加入队列
        _messageQueue.add({
          'event': event,
          'data': data,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });
        return false;
      }

      _coreSocket?.emitWithAck(event, data, ack: () {});

      return true;
    } catch (e) {
      if (kDebugMode) {
        print("[app_socket_io], sendEvent() error: $e");
      }
      return false;
    }
  }

  /// 发送队列中的消息
  void _sendQueuedMessages() {
    if (_messageQueue.isEmpty) return;

    final messagesToSend = List<Map<String, dynamic>>.from(_messageQueue);
    _messageQueue.clear();

    for (final message in messagesToSend) {
      sendEvent(message['event'], message['data']);
    }
  }

  /// 监听 socket 消息
  void _observe() {
    _observeConnectionStatus();
    _observeMessageEvents();
  }

  /// 监听 socket 连接状态
  void _observeConnectionStatus() {
    _coreSocket!.onConnect((data) {
      _connectStatus = SocketStatus.connected;
      _isReconnecting = false;
      _retryCount = 0;
      _stopReconnectTimer();
      _eventManager.notifyConnected(data);

      // 发送队列中的消息
      _sendQueuedMessages();
    });

    _coreSocket!.onConnecting((data) {
      _connectStatus = SocketStatus.connecting;
      _eventManager.notifyConnecting(data);
    });

    _coreSocket!.onDisconnect((data) async {
      _connectStatus = SocketStatus.disconnect;
      _eventManager.notifyDisconnected(data);

      // 自动重连
      if (_config?.enableAutoReconnect ?? true) {
        checkConnectStatus(shouldRetry: true);
      }
    });

    _coreSocket!.onConnectError((data) {
      _connectStatus = SocketStatus.error;
      _eventManager.notifyConnectError(data);
      _coreSocket?.disconnect();
    });

    _coreSocket!.onConnectTimeout((data) {
      _connectStatus = SocketStatus.timeout;
      _eventManager.notifyConnectTimeout(data);
    });
  }

  /// 监听 socket 消息事件
  void _observeMessageEvents() {
    _coreSocket!.on('messageEvent', (data) {
      _handleSocketData('messageEvent', data);
    });

    _coreSocket!.on('onInstructionEvent', (data) {
      _handleSocketData('onInstructionEvent', data);
    });

    _coreSocket!.on('responseEvent', (data) {
      _handleSocketData('responseEvent', data);
    });
  }

  /// 处理收到的数据
  void _handleSocketData(String event, Object? data) {
    _eventManager.notifyMessage(event, data);
  }

  /// 添加事件监听器
  void addEventListener(SocketEventListener listener) {
    _eventManager.addListener(listener);
  }

  /// 移除事件监听器
  void removeEventListener(SocketEventListener listener) {
    _eventManager.removeListener(listener);
  }

  /// 获取队列中的消息数量
  int get queuedMessageCount => _messageQueue.length;

  /// 清空消息队列
  void clearMessageQueue() {
    _messageQueue.clear();
  }

  /// 释放资源
  void dispose() {
    _eventManager.clearListeners();
    disconnect();
  }
}
