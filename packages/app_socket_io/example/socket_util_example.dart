import 'package:app_socket_io/app_socket_io.dart';

/// 应用层 Socket 工具类示例
class SocketUtilExample {
  SocketUtilExample._();

  static final List<ISocketEventHandler> _eventHandlers = [];
  static final Map<String, bool> _commandIDs = {};
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    SocketConfig config = SocketConfig.defaultConfig(
      isLoggedIn: () async {
        return true;
      },
      token: () async {
        return "1512371589as81";
      },
      headers: () async {
        return {
          "header1": "value",
          "header2": "value",
        };
      },
      socketPath: "https://www.xxx.com",
    );
    GlobalSocketConfig.setGlobalConfig(config);
    // 注册事件处理器
    registerEventHandler(Test1EventHandler());
    registerEventHandler(Test2EventHandler());
    _isInitialized = true;
  }

  static Future<void> connect() async {
    await AppSocketManager().connect();
    AppSocketManager().addEventListener(AppSocketEventListener());
  }

  static void dispose() {
    AppSocketManager().dispose();
    _commandIDs.clear();
  }

  static void registerEventHandler(ISocketEventHandler handler) {
    _eventHandlers.add(handler);
  }

  /// 处理收到的数据
  static void _handleSocketData(Map<String, dynamic> socketData) {
    // 委托给注册的事件处理器
    for (final handler in _eventHandlers) {
      if (handler.canHandle("key")) {
        handler.handle(socketData);
        break;
      }
    }
  }
}

/// Socket 事件监听器实现
class AppSocketEventListener extends DefaultSocketEventListener {
  @override
  void onConnected(Object? data) {
    print("socket onConnected");
  }

  @override
  void onDisconnected(Object? data) {
    print("socket onDisconnected");
  }

  @override
  void onMessage(String event, Object? data) {
    if (data is Map<String, dynamic>) {
      SocketUtilExample._handleSocketData(data);
    } else {
      print("Socket message is not Map<String, dynamic>");
    }
  }

  @override
  void onReconnectAttempt(int attempt, int maxAttempts) {
    super.onReconnectAttempt(attempt, maxAttempts);
  }

  @override
  void onReconnectFailed() {
    super.onReconnectFailed();
  }
}

/// 测试1事件处理器
class Test1EventHandler implements ISocketEventHandler {
  @override
  bool canHandle(String command) {
    return command == "test1";
  }

  @override
  void handle(Map<String, dynamic> data) {
    // 处理测试1事件
  }
}

/// 测试2事件处理器
class Test2EventHandler implements ISocketEventHandler {
  @override
  bool canHandle(String command) {
    return command == "test2";
  }

  @override
  void handle(Map<String, dynamic> data) {
    // 处理测试2事件
  }
}

/// Socket 事件处理器接口
abstract class ISocketEventHandler {
  bool canHandle(String command);

  void handle(Map<String, dynamic> data);
}
