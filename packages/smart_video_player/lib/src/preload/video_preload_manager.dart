import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:smart_video_player/src/preload/file_cache_manager.dart';

/// 视频下载优先级
enum VideoDownloadPriority {
  /// 高优先级 - 当前正在查看的视频
  high,

  /// 中优先级 - 相邻的视频
  medium,

  /// 低优先级 - 其他视频
  low,
}

/// 视频下载任务
class VideoDownloadTask {
  /// 视频URL
  final String videoUrl;

  /// 优先级
  final VideoDownloadPriority priority;

  /// 创建时间
  final DateTime createdAt;

  VideoDownloadTask({
    required this.videoUrl,
    required this.priority,
  }) : createdAt = DateTime.now();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VideoDownloadTask &&
          runtimeType == other.runtimeType &&
          videoUrl == videoUrl;

  @override
  int get hashCode => videoUrl.hashCode;
}

/// 视频下载状态
enum VideoDownloadStatus {
  /// 未开始
  idle,

  /// 等待中
  pending,

  /// 下载中
  downloading,

  /// 已完成
  completed,

  /// 失败
  failed,
}

/// 视频预加载管理器
class VideoPreloadManager {
  static final String _tag = 'VideoPreloadManager';

  static final VideoPreloadManager _instance = VideoPreloadManager._internal();

  factory VideoPreloadManager() => _instance;

  VideoPreloadManager._internal();

  /// 文件缓存管理器
  final FileCacheManager _cacheManager = FileCacheManager();

  /// 下载队列（使用优先级队列）
  final Queue<VideoDownloadTask> _downloadQueue = Queue<VideoDownloadTask>();

  /// 正在下载的任务集合（用于去重）
  final Set<String> _downloadingUrls = <String>{};

  /// 已完成的任务集合
  final Set<String> _completedUrls = <String>{};

  /// 失败的任务集合
  final Set<String> _failedUrls = <String>{};

  /// 下载状态映射
  final Map<String, VideoDownloadStatus> _statusMap =
      <String, VideoDownloadStatus>{};

  /// 是否正在处理队列
  bool _isProcessing = false;

  /// 最大并发下载数
  final int maxConcurrentDownloads = 2;

  /// 当前并发下载数
  int _currentDownloads = 0;

  /// 下载取消控制器映射
  final Map<String, Completer<void>> _cancelCompleters =
      <String, Completer<void>>{};

  /// 添加视频预加载任务
  ///
  /// [videoUrl] 视频URL
  /// [index] 视频索引
  /// [priority] 优先级
  /// [force] 是否强制重新下载
  Future<void> addTask({
    required String videoUrl,
    required int index,
    VideoDownloadPriority priority = VideoDownloadPriority.medium,
    bool force = false,
  }) async {
    if (videoUrl.isEmpty) return;

    // 如果已经完成，直接返回
    if (_completedUrls.contains(videoUrl) && !force) {
      _mLog('Video has been cached. Skip: $videoUrl', tag: _tag);
      return;
    }

    // 如果正在下载，不重复添加
    if (_downloadingUrls.contains(videoUrl)) {
      _mLog('Video is being downloaded. Skip: $videoUrl', tag: _tag);
      return;
    }

    // 检查本地缓存是否存在
    final cachedFile = await _cacheManager.getFileFromCache(videoUrl);
    if (cachedFile != null && !force) {
      _completedUrls.add(videoUrl);
      _statusMap[videoUrl] = VideoDownloadStatus.completed;
      _mLog('The video is already in the cache: $videoUrl', tag: _tag);
      return;
    }

    // 创建下载任务
    final task = VideoDownloadTask(
      videoUrl: videoUrl,
      priority: priority,
    );

    // 根据优先级插入队列
    _insertTaskByPriority(task);
    _statusMap[videoUrl] = VideoDownloadStatus.pending;

    // 开始处理队列
    _processQueue();
  }

  /// 根据优先级插入任务
  void _insertTaskByPriority(VideoDownloadTask task) {
    // 移除队列中相同URL的旧任务
    _downloadQueue.removeWhere((t) => t.videoUrl == task.videoUrl);

    if (_downloadQueue.isEmpty) {
      _downloadQueue.add(task);
      return;
    }

    // 转换为列表以便排序
    final list = _downloadQueue.toList();
    list.add(task);

    // 按优先级排序（高优先级在前）
    list.sort((a, b) {
      final priorityCompare = a.priority.index.compareTo(b.priority.index);
      if (priorityCompare != 0) return priorityCompare;
      // 优先级相同时，按创建时间排序
      return a.createdAt.compareTo(b.createdAt);
    });

    // 清空并重新添加
    _downloadQueue.clear();
    _downloadQueue.addAll(list);
  }

  /// 处理下载队列
  Future<void> _processQueue() async {
    if (_isProcessing) return;
    _isProcessing = true;

    while (_downloadQueue.isNotEmpty &&
        _currentDownloads < maxConcurrentDownloads) {
      final task = _downloadQueue.removeFirst();

      // 再次检查是否已下载或正在下载
      if (_completedUrls.contains(task.videoUrl) ||
          _downloadingUrls.contains(task.videoUrl)) {
        continue;
      }

      _currentDownloads++;
      _downloadTask(task).then((_) {
        _currentDownloads--;
        // 继续处理队列
        if (_downloadQueue.isNotEmpty) {
          _isProcessing = false;
          _processQueue();
        }
      });
    }

    _isProcessing = false;
  }

  /// 下载单个任务
  Future<void> _downloadTask(VideoDownloadTask task) async {
    final videoUrl = task.videoUrl;
    _downloadingUrls.add(videoUrl);
    _statusMap[videoUrl] = VideoDownloadStatus.downloading;

    // 创建取消控制器
    final cancelCompleter = Completer<void>();
    _cancelCompleters[videoUrl] = cancelCompleter;

    try {
      // 下载文件
      await _cacheManager
          .downloadFile(
        videoUrl,
        force: false,
      )
          .timeout(
        const Duration(minutes: 5),
        onTimeout: () {
          throw TimeoutException('Video download has timed out.');
        },
      );

      // 检查是否被取消
      if (cancelCompleter.isCompleted) {
        return;
      }

      _completedUrls.add(videoUrl);
      _failedUrls.remove(videoUrl);
      _statusMap[videoUrl] = VideoDownloadStatus.completed;
    } catch (e) {
      _mLog('Video download failed: $videoUrl, error: $e', tag: _tag);
      _failedUrls.add(videoUrl);
      _statusMap[videoUrl] = VideoDownloadStatus.failed;
    } finally {
      _downloadingUrls.remove(videoUrl);
      _cancelCompleters.remove(videoUrl);
    }
  }

  /// 批量预加载相邻视频（适用于混合列表场景，当前项可能不是视频）
  ///
  /// [currentMediaUrl] 当前媒体项的URL（可以是图片或视频）
  /// [allMediaUrls] 所有媒体项URL列表（混合图片和视频）
  /// [videoUrls] 纯视频URL列表
  /// [preloadCount] 预加载数量（在混合列表中前后各查找多少个视频）
  Future<void> preloadAdjacentVideosFromMixedList({
    required String currentMediaUrl,
    required List<String> allMediaUrls,
    required List<String> videoUrls,
    int preloadCount = 2,
  }) async {
    if (allMediaUrls.isEmpty || videoUrls.isEmpty || currentMediaUrl.isEmpty) {
      return;
    }

    final currentIndex = allMediaUrls.indexOf(currentMediaUrl);
    if (currentIndex == -1) return;

    try {
      final videoSet = videoUrls.toSet();
      final videosToPreload = <String>{};

      // 当前项是视频则加入
      if (videoSet.contains(currentMediaUrl)) {
        videosToPreload.add(currentMediaUrl);
      }

      /// 封装一个“按方向循环查找视频”的函数
      /// direction = -1 → 向前，+1 → 向后
      Future<void> search(int direction) async {
        int found = 0;
        int step = 1;
        final len = allMediaUrls.length;

        while (found < preloadCount) {
          int idx = (currentIndex + direction * step) % len;
          if (idx < 0) idx += len; // 处理负数取模

          final url = allMediaUrls[idx];
          if (videoSet.contains(url) && !videosToPreload.contains(url)) {
            videosToPreload.add(url);
            found++;
          }

          step++;

          // 避免死循环：如果全列表视频数量 < preloadCount，也会自动停止
          if (step > len) break;
        }
      }

      // 向前循环查找 preloadCount 个
      await search(-1);

      // 向后循环查找 preloadCount 个
      await search(1);

      // ============== 开始执行预加载任务 ==============
      for (final url in videosToPreload) {
        final indexInVideoList = videoUrls.indexOf(url);
        if (indexInVideoList == -1) continue;

        final bool isHighPriority =
            url == currentMediaUrl || url == videosToPreload.first;

        await addTask(
          videoUrl: url,
          index: indexInVideoList,
          priority: isHighPriority
              ? VideoDownloadPriority.high
              : VideoDownloadPriority.medium,
        );
      }
    } catch (e) {
      _mLog(
        'Preloading adjacent videos failed: currentMediaUrl=$currentMediaUrl, error=$e',
        tag: _tag,
      );
    }
  }

  /// 取消指定视频的下载
  void cancelDownload(String videoUrl) {
    if (_cancelCompleters.containsKey(videoUrl)) {
      _cancelCompleters[videoUrl]?.complete();
      _cancelCompleters.remove(videoUrl);
    }

    // 从队列中移除
    _downloadQueue.removeWhere((task) => task.videoUrl == videoUrl);
    _downloadingUrls.remove(videoUrl);
    _statusMap[videoUrl] = VideoDownloadStatus.idle;
  }

  /// 清理远离当前位置的缓存（适用于混合列表场景）
  ///
  /// [currentMediaUrl] 当前媒体项的URL（可以是图片或视频）
  /// [allMediaUrls] 所有媒体项URL列表（混合图片和视频）
  /// [videoUrls] 纯视频URL列表
  /// [keepRange] 保持范围（在视频序列中前后各保留多少个视频）
  void cleanupDistantCache({
    required String currentMediaUrl,
    required List<String> allMediaUrls,
    required List<String> videoUrls,
    int keepRange = 3,
  }) {
    if (allMediaUrls.isEmpty || videoUrls.isEmpty || currentMediaUrl.isEmpty) {
      return;
    }

    // 在混合列表中找到当前项的索引
    final currentIndex = allMediaUrls.indexOf(currentMediaUrl);
    if (currentIndex == -1) return;

    final videoSet = videoUrls.toSet();
    final videosToKeep = <String>{};

    // 当前项是视频则保留
    if (videoSet.contains(currentMediaUrl)) {
      videosToKeep.add(currentMediaUrl);
    }

    /// 封装：按方向循环查找 keepRange 个视频
    /// direction = -1 (向前)，+1 (向后)
    void search(int direction) {
      int found = 0;
      int step = 1;
      final len = allMediaUrls.length;

      while (found < keepRange) {
        int idx = (currentIndex + direction * step) % len;
        if (idx < 0) idx += len;

        final url = allMediaUrls[idx];
        if (videoSet.contains(url) && !videosToKeep.contains(url)) {
          videosToKeep.add(url);
          found++;
        }

        step++;

        // 避免死循环：扫描全列表后仍找不到就停止
        if (step > len) break;
      }
    }

    // 向前循环保留 keepRange 个
    search(-1);

    // 向后循环保留 keepRange 个
    search(1);

    // =========== 开始清理不需要的缓存 ===========
    for (final url in videoUrls) {
      if (!videosToKeep.contains(url)) {
        // 取消下载
        if (_downloadingUrls.contains(url)) {
          cancelDownload(url);
        }

        // 从下载队列中移除
        _downloadQueue.removeWhere((task) => task.videoUrl == url);
      }
    }
  }

  /// 获取视频下载状态
  VideoDownloadStatus getStatus(String videoUrl) {
    return _statusMap[videoUrl] ?? VideoDownloadStatus.idle;
  }

  /// 检查视频是否已缓存
  Future<bool> isCached(String videoUrl) async {
    if (_completedUrls.contains(videoUrl)) {
      return true;
    }
    final cachedFile = await _cacheManager.getFileFromCache(videoUrl);
    if (cachedFile != null) {
      _completedUrls.add(videoUrl);
      return true;
    }
    return false;
  }

  /// 获取缓存的视频文件
  Future<FileInfo?> getCachedVideo(String videoUrl) async {
    return await _cacheManager.getFileFromCache(videoUrl);
  }

  /// 清空所有任务
  void clearAll() {
    // 取消所有下载
    _cancelCompleters.forEach((url, completer) {
      if (!completer.isCompleted) {
        completer.complete();
      }
    });
    _cancelCompleters.clear();

    _downloadQueue.clear();
    _downloadingUrls.clear();
    _statusMap.clear();
    _currentDownloads = 0;
    _isProcessing = false;
  }

  /// 获取队列信息（用于调试）
  Map<String, dynamic> getQueueInfo() {
    return {
      'queueSize': _downloadQueue.length,
      'downloadingCount': _downloadingUrls.length,
      'completedCount': _completedUrls.length,
      'failedCount': _failedUrls.length,
      'currentDownloads': _currentDownloads,
      'isProcessing': _isProcessing,
    };
  }

  /// 打印队列状态
  void printQueueStatus() {
    final info = getQueueInfo();
    _mLog('Video download queue status: $info', tag: _tag);
  }
}

void _mLog(String content, {String tag = ''}) {
  if (kDebugMode) {
    print('[$tag], $content');
  }
}
