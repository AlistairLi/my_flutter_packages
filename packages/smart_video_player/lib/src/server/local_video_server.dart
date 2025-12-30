import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

/// 本地视频服务器
/// 用于从内存中流式提供视频数据，避免文件落盘
class LocalVideoServer {
  LocalVideoServer._();

  static final LocalVideoServer _instance = LocalVideoServer._();

  static LocalVideoServer get instance => _instance;

  HttpServer? _server;
  final Map<String, Uint8List> _videoCache = {};
  int _port = 18080;

  bool get isRunning => _server != null;

  String get baseUrl => 'http://127.0.0.1:$_port';

  /// 启动服务器
  Future<bool> start() async {
    if (_server != null) return true;

    try {
      _server = await HttpServer.bind(
        InternetAddress.loopbackIPv4,
        _port,
        shared: true,
      );

      _server!.listen(_handleRequest);
      return true;
    } catch (e) {
      // 尝试其他端口
      for (var port = 18081; port < 18090; port++) {
        try {
          _port = port;
          _server = await HttpServer.bind(
            InternetAddress.loopbackIPv4,
            _port,
            shared: true,
          );
          _server!.listen(_handleRequest);
          return true;
        } catch (_) {
          continue;
        }
      }
      return false;
    }
  }

  /// 停止服务器
  Future<void> stop() async {
    await _server?.close(force: true);
    _server = null;
    _videoCache.clear();
  }

  /// 添加视频到缓存
  String addVideo(String videoId, Uint8List videoData) {
    _videoCache[videoId] = videoData;
    return getVideoUrl(videoId);
  }

  /// 获取视频URL
  String getVideoUrl(String videoId) {
    return '$baseUrl/video/$videoId';
  }

  /// 移除视频缓存
  void removeVideo(String videoId) {
    _videoCache.remove(videoId);
  }

  /// 清空所有视频缓存
  void clearCache() {
    _videoCache.clear();
  }

  /// 处理HTTP请求
  void _handleRequest(HttpRequest request) async {
    final path = request.uri.path;

    // 只处理 /video/{videoId} 路径
    if (!path.startsWith('/video/')) {
      request.response
        ..statusCode = HttpStatus.notFound
        ..write('Not Found')
        ..close();
      return;
    }

    final videoId = path.substring('/video/'.length);
    final videoData = _videoCache[videoId];

    if (videoData == null) {
      request.response
        ..statusCode = HttpStatus.notFound
        ..write('Video not found: $videoId')
        ..close();
      return;
    }

    try {
      final rangeHeader = request.headers.value(HttpHeaders.rangeHeader);

      if (rangeHeader != null) {
        // 处理 Range 请求（支持视频 seek）
        await _handleRangeRequest(request, videoData, rangeHeader);
      } else {
        // 返回完整视频
        request.response
          ..statusCode = HttpStatus.ok
          ..headers.contentType = ContentType('video', 'mp4')
          ..headers.contentLength = videoData.length
          ..headers.set(HttpHeaders.acceptRangesHeader, 'bytes')
          ..add(videoData)
          ..close();
      }
    } catch (e) {
      request.response
        ..statusCode = HttpStatus.internalServerError
        ..write('Internal Server Error')
        ..close();
    }
  }

  /// 处理 Range 请求，支持视频 seek 和拖动进度条
  Future<void> _handleRangeRequest(
    HttpRequest request,
    Uint8List videoData,
    String rangeHeader,
  ) async {
    // 解析 Range: bytes=start-end
    final match = RegExp(r'bytes=(\d*)-(\d*)').firstMatch(rangeHeader);
    if (match == null) {
      request.response
        ..statusCode = HttpStatus.badRequest
        ..write('Invalid Range header')
        ..close();
      return;
    }

    final totalLength = videoData.length;
    int start = 0;
    int end = totalLength - 1;

    final startStr = match.group(1);
    final endStr = match.group(2);

    if (startStr != null && startStr.isNotEmpty) {
      start = int.parse(startStr);
    }
    if (endStr != null && endStr.isNotEmpty) {
      end = int.parse(endStr);
    }

    // 验证范围
    if (start >= totalLength || end >= totalLength || start > end) {
      request.response
        ..statusCode = HttpStatus.requestedRangeNotSatisfiable
        ..headers.set(HttpHeaders.contentRangeHeader, 'bytes */$totalLength')
        ..close();
      return;
    }

    final contentLength = end - start + 1;
    final chunk = videoData.sublist(start, end + 1);

    request.response
      ..statusCode = HttpStatus.partialContent
      ..headers.contentType = ContentType('video', 'mp4')
      ..headers.contentLength = contentLength
      ..headers.set(HttpHeaders.acceptRangesHeader, 'bytes')
      ..headers.set(
        HttpHeaders.contentRangeHeader,
        'bytes $start-$end/$totalLength',
      )
      ..add(chunk)
      ..close();
  }
}
