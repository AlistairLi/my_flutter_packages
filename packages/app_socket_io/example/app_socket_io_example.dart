import 'package:app_socket_io/app_socket_io.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Socket.IO Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SocketExamplePage(),
    );
  }
}

class SocketExamplePage extends StatefulWidget {
  @override
  _SocketExamplePageState createState() => _SocketExamplePageState();
}

class _SocketExamplePageState extends State<SocketExamplePage>
    implements SocketEventListener {
  final AppSocketManager _socketManager = AppSocketManager();
  String _status = '未连接';
  List<String> _messages = [];

  @override
  void initState() {
    super.initState();
    _setupSocket();
  }

  void _setupSocket() {
    // 设置全局配置
    GlobalSocketConfig.setGlobalConfig(
      SocketConfig.defaultConfig(
        isLoggedIn: () => Future.value(true),
        // 模拟已登录
        token: () async {
          return "your_token_here";
        },
        headers: () async {
          return {'Authorization': 'Bearer your_token_here'};
        },
        version: '1.0.0',
        socketPath: 'wss://your-socket-server.com',
      ),
    );

    // 添加事件监听器
    _socketManager.addEventListener(this);
  }

  @override
  void dispose() {
    _socketManager.removeEventListener(this);
    _socketManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Socket.IO 示例'),
        actions: [
          IconButton(
            icon:
                Icon(_socketManager.isConnected ? Icons.wifi : Icons.wifi_off),
            onPressed: () {
              if (_socketManager.isConnected) {
                _socketManager.disconnect();
              } else {
                _socketManager.connect();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 状态显示
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.grey[200],
            child: Row(
              children: [
                Text('状态: $_status'),
                SizedBox(width: 16),
                if (_socketManager.isReconnecting)
                  CircularProgressIndicator(strokeWidth: 2),
                if (_socketManager.queuedMessageCount > 0)
                  Text('队列消息: ${_socketManager.queuedMessageCount}'),
              ],
            ),
          ),

          // 控制按钮
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: () => _socketManager.connect(),
                  child: Text('连接'),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _socketManager.disconnect(),
                  child: Text('断开'),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _sendTestMessage(),
                  child: Text('发送测试消息'),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _socketManager.clearMessageQueue(),
                  child: Text('清空队列'),
                ),
              ],
            ),
          ),

          // 消息列表
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_messages[index]),
                  dense: true,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _sendTestMessage() async {
    final success = await _socketManager.sendEvent(
      'testEvent',
      {
        'message': 'Hello from Flutter!',
        'timestamp': DateTime.now().toString()
      },
    );

    if (success) {
      _addMessage('✅ 消息发送成功');
    } else {
      _addMessage('❌ 消息发送失败（可能已加入队列）');
    }
  }

  void _addMessage(String message) {
    setState(() {
      _messages.insert(
          0, '${DateTime.now().toString().substring(11, 19)}: $message');
      if (_messages.length > 50) {
        _messages.removeLast();
      }
    });
  }

  // SocketEventListener 实现
  @override
  void onConnected(Object? data) {
    setState(() {
      _status = '已连接';
    });
    _addMessage('🔗 Socket 连接成功');
  }

  @override
  void onConnecting(Object? data) {
    setState(() {
      _status = '连接中...';
    });
    _addMessage('🔄 Socket 连接中...');
  }

  @override
  void onDisconnected(Object? data) {
    setState(() {
      _status = '已断开';
    });
    _addMessage('🔌 Socket 连接断开');
  }

  @override
  void onError(Object? data) {
    setState(() {
      _status = '连接错误';
    });
    _addMessage('❌ Socket 连接错误: $data');
  }

  @override
  void onTimeout(Object? data) {
    setState(() {
      _status = '连接超时';
    });
    _addMessage('⏰ Socket 连接超时');
  }

  @override
  void onMessage(String event, Object? data) {
    _addMessage('📨 收到消息 [$event]: $data');
  }

  @override
  void onReconnectAttempt(int attempt, int maxAttempts) {
    _addMessage('🔄 重连尝试 $attempt/$maxAttempts');
  }

  @override
  void onReconnectSuccess() {
    _addMessage('✅ 重连成功');
  }

  @override
  void onReconnectFailed() {
    _addMessage('❌ 重连失败');
  }
}
