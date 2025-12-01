import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:smart_video_player/smart_video_player.dart';
import 'package:smart_video_player/src/better/normal/normal_video_controller.dart';
import 'package:smart_video_player/src/preload/file_cache_manager.dart';

/// 普通视频播放器组件
///
/// 基于 BetterPlayer 实现的视频播放器，支持多种视频源类型和自定义配置
/// 注意：不建议在PageView中使用，会存在一些问题，暂时还没解决，可以使用 [VideoPager]。
class NormalVideoPlayer extends StatefulWidget {
  const NormalVideoPlayer({
    super.key,
    required this.width,
    required this.height,
    required this.videoUrl,
    required this.sourceType,
    this.fit = BoxFit.cover,
    this.autoPlay = false,
    this.overlay,
    this.controller,
  });

  final double width;

  final double height;

  /// 视频地址
  final String videoUrl;

  /// 源类型
  final SmartVideoSourceType sourceType;

  /// 适配方式
  final BoxFit fit;

  /// 是否自动播放, 默认为 true
  final bool autoPlay;

  final Widget? overlay;

  final NormalVideoController? controller;

  @override
  State<NormalVideoPlayer> createState() => _NormalVideoPlayerState();
}

class _NormalVideoPlayerState extends State<NormalVideoPlayer> {
  late BetterPlayerController _betterPlayerController;

  @override
  void initState() {
    BetterPlayerConfiguration betterPlayerConfiguration =
        BetterPlayerConfiguration(
      aspectRatio: getAspectRatio(),
      fit: widget.fit,
      autoPlay: widget.autoPlay,
      overlay: widget.overlay,
      looping: true,
      deviceOrientationsAfterFullScreen: [
        DeviceOrientation.portraitDown,
        DeviceOrientation.portraitUp
      ],
    );
    _betterPlayerController = BetterPlayerController(betterPlayerConfiguration);
    widget.controller?.attachPlayer(_betterPlayerController);
    _setupDataSource();
    super.initState();
  }

  @override
  void dispose() {
    widget.controller?.dispose();
    super.dispose();
  }

  double getAspectRatio() {
    return widget.width / widget.height;
  }

  Future<void> _setupDataSource() async {
    BetterPlayerDataSourceType type;
    var url = widget.videoUrl;
    if (widget.sourceType == SmartVideoSourceType.file) {
      type = BetterPlayerDataSourceType.file;
    } else if (widget.sourceType == SmartVideoSourceType.network) {
      FileInfo? cacheFileInfo = await FileCacheManager().getFileFromCache(url);
      if (cacheFileInfo != null) {
        type = BetterPlayerDataSourceType.file;
      } else {
        type = BetterPlayerDataSourceType.network;
      }
    } else {
      type = BetterPlayerDataSourceType.memory;
    }
    BetterPlayerDataSource dataSource = BetterPlayerDataSource(type, url);

    _betterPlayerController.setupDataSource(dataSource);
  }

  @override
  Widget build(BuildContext context) {
    return BetterPlayer(controller: _betterPlayerController);
  }
}
