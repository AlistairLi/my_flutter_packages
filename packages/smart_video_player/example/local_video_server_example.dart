import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:smart_video_player/smart_video_player.dart';

class LocalVideoServerExample extends StatefulWidget {
  const LocalVideoServerExample({super.key});

  @override
  State<LocalVideoServerExample> createState() =>
      _LocalVideoServerExampleState();
}

class _LocalVideoServerExampleState extends State<LocalVideoServerExample> {
  final LocalVideoServer _localVideoServer = LocalVideoServer.instance;
  String? _videoUrl;

  @override
  void initState() {
    super.initState();
    _startVideoServer();
  }

  Future<void> _startVideoServer() async {
    // 启动本地视频服务器
    final started = await _localVideoServer.start();
    if (started) {
      print('Local video server started at ${_localVideoServer.baseUrl}');
    } else {
      print('Failed to start local video server');
    }
  }

  // 模拟添加视频数据到服务器
  Future<void> _addVideoToServer() async {
    // 这里应该从实际的视频数据源获取 Uint8List 数据
    // 例如从 assets、网络或文件读取
    final videoId = 'sample_video';
    final videoData = await _loadSampleVideoData();

    // 将视频数据添加到服务器
    final url = _localVideoServer.addVideo(videoId, videoData);
    setState(() {
      _videoUrl = url;
    });
  }

  // 模拟加载视频数据的方法
  Future<Uint8List> _loadSampleVideoData() async {
    // 实际项目中需要从某个地方加载视频数据
    // 这里返回一个空的 Uint8List 作为示例
    return Uint8List(0);
  }

  @override
  void dispose() {
    // 停止服务器并清理资源
    _localVideoServer.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Local Video Server Example'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: _addVideoToServer,
            child: const Text('Add Video to Server'),
          ),
          if (_videoUrl != null)
            Expanded(
              child: SmartVideoPlayer(
                videoUrl: _videoUrl!,
                sourceType: SmartVideoSourceType.network,
              ),
            )
          else
            const Expanded(
              child: Center(
                child: Text('Press button to add video to local server'),
              ),
            ),
        ],
      ),
    );
  }
}
