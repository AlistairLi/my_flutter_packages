import 'package:flutter/material.dart';
import 'package:smart_video_player/smart_video_player.dart';

/// 视频预加载
class VideoPreloadExample extends StatefulWidget {
  const VideoPreloadExample({super.key});

  @override
  State<VideoPreloadExample> createState() => _VideoPreloadExampleState();
}

class _VideoPreloadExampleState extends State<VideoPreloadExample> {
  final SmartVideoPlayerController _videoController =
      SmartVideoPlayerController();

  /// 视频预加载管理器
  final VideoPreloadManager _videoPreloadManager = VideoPreloadManager();

  final List<String> _paths = [
    'https://vod.dongfang.tv/vod/2022/07/07/20220707000000000000000000000001.mp4',
  ];

  /// 预加载相邻视频
  ///
  /// [currentIndex] 当前视频索引
  /// [mediaList] 媒体列表
  Future<void> preloadAdjacentVideos(
      int currentIndex, List<String> mediaList) async {
    if (mediaList.isEmpty) return;
    var urls = List<String>.from(mediaList);
    var currentUrl = urls[currentIndex];

    // 调用预加载管理器
    await _videoPreloadManager.preloadAdjacentVideosFromMixedList(
      currentMediaUrl: currentUrl,
      videoUrls: urls,
      allMediaUrls: urls,
      preloadCount: 2, // 前后各预加载2个视频
    );

    // 打印队列状态（用于调试）
    _videoPreloadManager.printQueueStatus();
  }

  /// 清理远离当前位置的视频缓存
  ///
  /// [currentIndex] 当前视频索引
  /// [mediaList] 媒体列表
  void cleanupDistantVideos(int currentIndex, List<String> mediaList) {
    // 过滤出所有视频URL
    final videoUrls = <String>[];
    for (var value in mediaList) {
      videoUrls.add(value);
    }

    if (videoUrls.isEmpty) return;

    // // 清理远离当前位置的缓存
    // _videoPreloadManager.cleanupDistantCache(
    //   currentIndex: currentIndex,
    //   videoUrls: videoUrls,
    //   keepRange: 3, // 保持前后各3个视频
    // );
  }

  @override
  void initState() {
    super.initState();
    preloadAdjacentVideos(0, _paths);
  }

  @override
  void dispose() {
    _videoPreloadManager.clearAll();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        itemCount: _paths.length,
        controller: PageController(initialPage: 0),
        itemBuilder: (context, index) {
          return SmartVideoPlayer(
            videoUrl: _paths[index],
            fit: BoxFit.cover,
            sourceType: SmartVideoSourceType.network,
            controller: _videoController,
          );
        },
        onPageChanged: (index) {
          // 预加载相邻视频到本地
          preloadAdjacentVideos(index, _paths);
          // 清理远离当前位置的视频缓存
          cleanupDistantVideos(index, _paths);
        },
      ),
    );
  }
}
