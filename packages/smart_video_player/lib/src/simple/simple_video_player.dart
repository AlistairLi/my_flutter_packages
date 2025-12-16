import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:smart_video_player/src/preload/file_cache_manager.dart';
import 'package:smart_video_player/src/simple/simple_video_controller.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector_widget/visibility_detector_widget.dart';

import '../config/smart_video_source_type.dart';

/// 简单的播放视频组件，基于chewie实现
///
/// 1. 没有点击播放/暂停功能。
/// 2. 适用于播放单个视频时使用。
class SimpleVideoPlayer extends StatefulWidget {
  /// 视频地址
  final String videoUrl;

  /// 视频封面
  final String? cover;

  final ImageProvider? coverImageProvider;

  /// 源类型
  final SmartVideoSourceType sourceType;

  /// 适配方式
  final BoxFit fit;

  /// 是否保持播放器状态
  final bool keepAlive;

  /// 是否自动播放
  final bool autoPlay;

  /// 循环播放
  final bool looping;

  /// 是否显示 Loading
  final bool showLoading;

  /// 视频播放控制器
  final SimpleVideoController? controller;

  /// 视频音量，数值在 0.0（静音）到 1.0（全音量）之间
  final double volume;

  /// 视频开始播放回调
  final VoidCallback? onVideoStarted;

  /// 视频播放结束回调（当 looping=false 时触发）
  final VoidCallback? onVideoEnded;

  const SimpleVideoPlayer({
    super.key,
    required this.videoUrl,
    this.cover,
    this.coverImageProvider,
    required this.sourceType,
    this.fit = BoxFit.contain,
    this.keepAlive = true,
    this.autoPlay = true,
    this.looping = false,
    this.showLoading = true,
    this.controller,
    this.volume = 1,
    this.onVideoStarted,
    this.onVideoEnded,
  });

  @override
  State<SimpleVideoPlayer> createState() => _SmartVideoPlayerState();
}

class _SmartVideoPlayerState extends State<SimpleVideoPlayer>
    with AutomaticKeepAliveClientMixin {
  late VideoPlayerController _videoController;
  ChewieController? _chewieController;
  bool _hasStartedPlaying = false;
  bool _hasNotifiedEnded = false;

  /// 初始化播放器
  Future<void> _initializePlayer() async {
    var path = widget.videoUrl;
    if (widget.sourceType == SmartVideoSourceType.file) {
      _videoController = VideoPlayerController.file(File(path));
    } else if (widget.sourceType == SmartVideoSourceType.network) {
      FileInfo? cacheFileInfo = await FileCacheManager().getFileFromCache(path);
      if (cacheFileInfo != null) {
        _videoController = VideoPlayerController.file(cacheFileInfo.file);
      } else {
        _videoController = VideoPlayerController.networkUrl(Uri.parse(path));
      }
    } else {
      _videoController = VideoPlayerController.asset(path);
    }

    await _videoController.initialize();
    _createChewieController();
    _addVideoListener();
    setState(() {});
  }

  /// 添加视频播放状态监听
  void _addVideoListener() {
    _videoController.addListener(() {
      if (!mounted) return;

      final isPlaying = _videoController.value.isPlaying;
      final position = _videoController.value.position;
      final duration = _videoController.value.duration;

      // 检测视频开始播放
      if (isPlaying && !_hasStartedPlaying) {
        _hasStartedPlaying = true;
        widget.onVideoStarted?.call();
      }

      // 检测视频播放结束（当不循环播放时）
      if (!widget.looping &&
          !_hasNotifiedEnded &&
          position >= duration &&
          duration > Duration.zero) {
        _hasNotifiedEnded = true;
        widget.onVideoEnded?.call();
      }
    });
  }

  void _createChewieController() {
    _chewieController = ChewieController(
      videoPlayerController: _videoController,
      autoPlay: widget.autoPlay,
      looping: widget.looping,
      showControls: false,
    );
    widget.controller?.attachPlayer(_chewieController);
  }

  /// 播放
  void _play() async {
    if (mounted) {
      var controller = _chewieController;
      if (controller != null) {
        var value = controller.videoPlayerController.value;
        if (value.isInitialized == true && value.isPlaying == true) {
          // 设置音频输出
          final AudioSession session = await AudioSession.instance;
          await session.configure(const AudioSessionConfiguration.music());
          if (mounted) {
            if (_chewieController != null) {
              _chewieController!.play();
              // setState(() {});
            }
          }
        }
      }
    }
  }

  /// 暂停
  void _pause() {
    if (mounted) {
      var controller = _chewieController;
      if (controller != null) {
        var value = controller.videoPlayerController.value;
        if (value.isInitialized == true && value.isPlaying == true) {
          controller.pause();
          // setState(() {});
        }
      }
    }
  }

  @override
  bool get wantKeepAlive => widget.keepAlive;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  @override
  void dispose() {
    _videoController.dispose();
    _chewieController?.dispose();
    widget.controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return VisibilityDetectorWidget(
      onVisible: () {
        _play();
      },
      onInvisible: () {
        _pause();
      },
      child: Stack(
        children: [
          if (_chewieController?.videoPlayerController.value.isInitialized !=
              true)
            Positioned.fill(
              child: Image(
                image: widget.coverImageProvider ??
                    NetworkImage(widget.cover ?? ""),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => SizedBox.shrink(),
              ),
            ),
          Positioned.fill(
            child: (_chewieController != null &&
                    _chewieController!
                            .videoPlayerController.value.isInitialized ==
                        true)
                ? ClipRRect(
                    child: AspectRatio(
                      aspectRatio: _chewieController!
                          .videoPlayerController.value.aspectRatio,
                      child: FittedBox(
                        fit: widget.fit,
                        child: SizedBox(
                          width: _chewieController!
                              .videoPlayerController.value.size.width,
                          height: _chewieController!
                              .videoPlayerController.value.size.height,
                          child: Chewie(
                            controller: _chewieController!,
                          ),
                        ),
                      ),
                    ),
                  )
                : (widget.showLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SizedBox.shrink()),
          ),
        ],
      ),
    );
  }
}
