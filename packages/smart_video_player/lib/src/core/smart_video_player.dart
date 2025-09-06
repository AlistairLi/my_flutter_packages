import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:smart_video_player/src/controller/smart_video_player_controller.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector_widget/visibility_detector_widget.dart';

enum SmartVideoSourceType {
  /// asset 资源
  asset,

  /// 本地文件
  file,

  /// 网络视频
  network,
}

/// 播放视频组件
class SmartVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final SmartVideoSourceType sourceType;

  /// 适配方式
  final BoxFit fit;

  /// 是否可点击播放/暂停
  final bool clickPlay;

  /// 是否保持播放器状态
  final bool keepAlive;

  /// 视频播放控制器
  final SmartVideoPlayerController? controller;

  /// 视频音量，数值在 0.0（静音）到 1.0（全音量）之间
  final double volume;

  const SmartVideoPlayer({
    super.key,
    required this.videoUrl,
    required this.sourceType,
    this.fit = BoxFit.contain,
    this.clickPlay = true,
    this.keepAlive = true,
    this.controller,
    this.volume = 1,
  });

  @override
  State<SmartVideoPlayer> createState() => _SmartVideoPlayerState();
}

class _SmartVideoPlayerState extends State<SmartVideoPlayer>
    with AutomaticKeepAliveClientMixin {
  late VideoPlayerController _videoController;
  late ChewieController _chewieController;
  late SmartVideoPlayerController _localController;

  /// 初始化播放器
  Future<void> _initPlayer() async {
    var path = widget.videoUrl;
    if (widget.sourceType == SmartVideoSourceType.file) {
      _videoController = VideoPlayerController.file(File(path));
    } else if (widget.sourceType == SmartVideoSourceType.network) {
      _videoController = VideoPlayerController.networkUrl(Uri.parse(path));
    } else {
      _videoController = VideoPlayerController.asset(path);
    }
    await _videoController.initialize();

    _chewieController = ChewieController(
      videoPlayerController: _videoController,
      autoPlay: true,
      looping: true,
      showControls: false,
    );
    _chewieController.setVolume(widget.volume);

    // 设置控制器状态
    _localController.setInitialized(true);
    _localController.setPlayingState(_videoController.value.isPlaying);

    // 监听播放状态变化
    _videoController.addListener(_onVideoPlayerStateChanged);

    if (mounted) {
      setState(() {});
    }
  }

  /// 监听视频播放器状态变化
  void _onVideoPlayerStateChanged() {
    if (mounted) {
      _localController.setPlayingState(_videoController.value.isPlaying);
    }
  }

  /// 暂停
  void _pause() {
    if (mounted) {
      if (_videoController.value.isInitialized == true &&
          _videoController.value.isPlaying == true) {
        _videoController.pause();
        setState(() {});
      }
    }
  }

  /// 播放
  void _play() async {
    if (mounted) {
      if (_videoController.value.isInitialized == true &&
          _videoController.value.isPlaying == false) {
        // 设置音频输出
        final AudioSession session = await AudioSession.instance;
        await session.configure(const AudioSessionConfiguration.music());

        _videoController.play();
        setState(() {});
      }
    }
  }

  /// 点击屏幕
  void _onTap() {
    _videoController.value.isPlaying == true ? _pause() : _play();
  }

  @override
  void initState() {
    super.initState();
    _localController = widget.controller ?? SmartVideoPlayerController();
    _initPlayer();
  }

  @override
  void dispose() {
    _videoController.removeListener(_onVideoPlayerStateChanged);
    _videoController.dispose();
    _chewieController.dispose();
    // 只销毁本地控制器，外部控制器由调用方管理
    if (widget.controller == null) {
      _localController.dispose();
    }
    super.dispose();
  }

  @override
  bool get wantKeepAlive => widget.keepAlive;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ListenableBuilder(
        listenable: _localController,
        builder: (context, child) {
          return VisibilityDetectorWidget(
            onVisible: () {
              _play();
            },
            onInvisible: () {
              _pause();
            },
            child: Stack(
              children: [
                Positioned.fill(
                  child: (_videoController.value.isInitialized == true)
                      ? ClipRRect(
                          child: AspectRatio(
                            aspectRatio: _videoController.value.aspectRatio,
                            child: FittedBox(
                              fit: widget.fit,
                              child: SizedBox(
                                width: _videoController.value.size.width,
                                height: _videoController.value.size.height,
                                child: Chewie(
                                  controller: _chewieController,
                                ),
                              ),
                            ),
                          ),
                        )
                      : const Center(child: CircularProgressIndicator()),
                ),
                if (widget.clickPlay)
                  Positioned.fill(
                    child: GestureDetector(
                      child: Center(
                        child: (_videoController.value.isInitialized == true) &&
                                (!_videoController.value.isPlaying)
                            ? Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.play_arrow_rounded,
                                  color: Colors.white,
                                  size: 55,
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        _onTap();
                      },
                    ),
                  ),
              ],
            ),
          );
        });
  }
}
