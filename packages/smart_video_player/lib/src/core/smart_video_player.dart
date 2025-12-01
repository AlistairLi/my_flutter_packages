import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:smart_video_player/smart_video_player.dart';
import 'package:smart_video_player/src/controller/smart_video_progress_controller.dart';
import 'package:smart_video_player/src/preload/file_cache_manager.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector_widget/visibility_detector_widget.dart';

/// 进度条配置类
class SmartVideoProgressBarConfig {
  /// 是否显示进度条
  final bool showProgressBar;

  /// 是否显示时间
  final bool showTime;

  /// 进度条高度
  final double height;

  /// 进度条背景颜色
  final Color backgroundColor;

  /// 已播放进度颜色
  final Color playedColor;

  /// 未播放进度颜色
  final Color unplayedColor;

  /// 拖拽指示器颜色
  final Color indicatorColor;

  /// 当前时间文本样式
  final TextStyle timeTextStyle;

  /// 总时间文本样式
  final TextStyle totalTimeTextStyle;

  /// 进度条圆角
  final double borderRadius;

  /// 进度条内边距
  final EdgeInsets padding;

  /// 是否显示渐变背景
  final bool showGradientBackground;

  /// 渐变背景颜色
  final List<Color> gradientColors;

  final bool isShowBackground;

  const SmartVideoProgressBarConfig({
    this.showProgressBar = true,
    this.showTime = false,
    this.height = 3,
    this.backgroundColor = const Color(0x4D000000),
    this.playedColor = Colors.white,
    this.unplayedColor = const Color(0xFF565656),
    this.indicatorColor = Colors.white,
    this.timeTextStyle = const TextStyle(color: Colors.white, fontSize: 22.0),
    this.totalTimeTextStyle =
        const TextStyle(color: Colors.white60, fontSize: 22.0),
    this.borderRadius = 2.0,
    this.padding =
        const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 50),
    this.showGradientBackground = true,
    this.gradientColors = const [
      Colors.transparent,
      Color(0xB3000000),
    ],
    this.isShowBackground = false,
  });

  /// 创建默认配置
  static const SmartVideoProgressBarConfig defaultConfig =
      SmartVideoProgressBarConfig();

  /// 创建隐藏进度条的配置
  static const SmartVideoProgressBarConfig hidden = SmartVideoProgressBarConfig(
    showProgressBar: false,
  );

  /// 创建简化配置（只显示进度条，不显示时间）
  static const SmartVideoProgressBarConfig simple = SmartVideoProgressBarConfig(
    showTime: false,
  );
}

/// 播放视频组件
/// 注意：当在滑动页面中，暂不支持预加载前后缓存，后续优化
class SmartVideoPlayer extends StatefulWidget {
  /// 视频地址
  final String videoUrl;

  /// 视频封面
  final String? cover;

  final ImageProvider? coverImageProvider;

  /// 源类型
  final SmartVideoSourceType sourceType;

  /// 适配方式
  final BoxFit fit;

  /// 是否可点击播放/暂停
  final bool clickPlay;

  /// 是否保持播放器状态
  final bool keepAlive;

  /// 是否自动播放
  // final bool autoPlay;

  /// 是否显示 Loading
  final bool showLoading;

  /// 视频播放控制器
  final SmartVideoPlayerController? controller;

  /// 视频音量，数值在 0.0（静音）到 1.0（全音量）之间
  final double volume;

  /// 进度条配置
  final SmartVideoProgressBarConfig? progressBarConfig;

  const SmartVideoPlayer({
    super.key,
    required this.videoUrl,
    this.cover,
    this.coverImageProvider,
    required this.sourceType,
    this.fit = BoxFit.contain,
    this.clickPlay = true,
    this.keepAlive = true,
    // this.autoPlay = true,
    this.showLoading = true,
    this.controller,
    this.volume = 1,
    this.progressBarConfig = SmartVideoProgressBarConfig.defaultConfig,
  });

  @override
  State<SmartVideoPlayer> createState() => _SmartVideoPlayerState();
}

class _SmartVideoPlayerState extends State<SmartVideoPlayer>
    with AutomaticKeepAliveClientMixin {
  final SmartVideoProgressController _progressController =
      SmartVideoProgressController();
  late SmartVideoPlayerController _localController;

  late VideoPlayerController _videoController;
  late ChewieController _chewieController;
  bool _isInit = false;

  /// 标记是否是手动暂停（用于控制播放按钮显示）
  bool _isManuallyPaused = false;

  /// 视频播放器状态变化监听器
  late var videoListener = () {
    if (mounted) {
      _localController.setPlayingState(_videoController.value.isPlaying);
      _progressController.updatePosition(_videoController.value.position);
      _progressController.updateDuration(_videoController.value.duration);
    }
  };

  /// 初始化播放器
  Future<void> _initPlayer() async {
    if (_isInit) return;
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

    // 监听播放状态变化
    _videoController.addListener(videoListener);

    _chewieController = ChewieController(
      videoPlayerController: _videoController,
      autoInitialize: true,
      autoPlay: true,
      looping: true,
      showControls: false,
    );
    _chewieController.setVolume(widget.volume);

    // 设置控制器状态
    _localController.setInitialized(true);
    _localController.setPlayingState(_videoController.value.isPlaying);

    _isInit = true;
  }

  /// 暂停
  void _pause({bool isManual = false}) {
    if (mounted && _isInit) {
      if (_videoController.value.isInitialized == true &&
          _videoController.value.isPlaying == true) {
        _videoController.pause();
        _isManuallyPaused = isManual;
        setState(() {});
      }
    }
  }

  /// 播放
  void _play({bool isManual = false}) async {
    if (mounted && _isInit) {
      if (_videoController.value.isInitialized == true &&
          _videoController.value.isPlaying == false) {
        // 设置音频输出
        final AudioSession session = await AudioSession.instance;
        await session.configure(const AudioSessionConfiguration.music());
        if (mounted) {
          _videoController.play();
          setState(() {});
        }
      }
    }
  }

  /// 点击屏幕
  void _onTap() {
    if (_isInit) {
      _videoController.value.isPlaying == true
          ? _pause(isManual: true)
          : _play(isManual: true);
    }
  }

  double _computeProgressH(double configH, bool isDragging) {
    return isDragging ? configH * 2 : configH;
  }

  double _computeIndicatorSize(double progressH) {
    return progressH * 2;
  }

  double _computeTouchHeight(double indicatorSize) {
    return indicatorSize * 1.8;
  }

  /// 构建进度条
  Widget _buildProgressBar() {
    final config =
        widget.progressBarConfig ?? SmartVideoProgressBarConfig.defaultConfig;

    return ListenableBuilder(
        listenable: _progressController,
        builder: (context, child) {
          var isDragging = _progressController.isDragging;

          var progressHeight = _computeProgressH(config.height, isDragging);
          var indicatorSize = _computeIndicatorSize(progressHeight);

          var touchHeight = _computeTouchHeight(indicatorSize);
          if (touchHeight < 36) {
            touchHeight = 36;
          }
          if (touchHeight < indicatorSize) {
            touchHeight = indicatorSize;
          }
          return Container(
            padding: config.padding,
            decoration: config.isShowBackground
                ? (config.showGradientBackground
                    ? BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: config.gradientColors,
                        ),
                      )
                    : BoxDecoration(
                        color: config.backgroundColor,
                      ))
                : null,
            child: Column(
              children: [
                if (isDragging)
                  Padding(
                    padding: EdgeInsets.only(bottom: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 当前时间
                        Text(
                          _localController
                              .formatDuration(_progressController.position),
                          style: config.timeTextStyle,
                        ),
                        Text(
                          ' / '
                          '',
                          style: config.totalTimeTextStyle,
                        ),
                        Text(
                          _localController
                              .formatDuration(_progressController.duration),
                          style: config.totalTimeTextStyle,
                        ),
                      ],
                    ),
                  ),
                // 进度条
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  // 长按拖拽
                  onLongPressStart: (details) {
                    _saveTouch(details.localPosition);
                    _progressController.setDragging(true);
                  },
                  onLongPressMoveUpdate: (details) {
                    _seekToPosition(details.localPosition);
                  },
                  onLongPressEnd: (details) {
                    _progressController.setDragging(false);
                    _onSeekEnd();
                  },
                  onLongPressCancel: () {
                    _progressController.setDragging(false);
                  },
                  // 直接滑动拖拽
                  // onPanDown: (details) {
                  //   _saveTouch(details.localPosition);
                  //   _progressController.setDragging(true);
                  // },
                  // onPanUpdate: (details) {
                  //   _seekToPosition(details.localPosition);
                  // },
                  // onPanEnd: (details) {
                  //   _progressController.setDragging(false);
                  //   _onSeekEnd();
                  // },
                  // onPanCancel: () {
                  //   _progressController.setDragging(false);
                  // },
                  child: SizedBox(
                    width: double.infinity,
                    height: touchHeight,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: double.infinity,
                          height: progressHeight,
                          margin: EdgeInsets.symmetric(
                              horizontal: indicatorSize / 2),
                          decoration: BoxDecoration(
                            color: config.unplayedColor,
                            borderRadius:
                                BorderRadius.circular(config.borderRadius),
                          ),
                          child: Stack(
                            children: [
                              // 已播放进度
                              FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: _progressController.progress,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: config.playedColor,
                                    borderRadius: BorderRadius.circular(
                                        config.borderRadius),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // 拖拽指示器
                        Positioned(
                          left: (_progressController.progress *
                              (MediaQuery.of(context).size.width -
                                  config.padding.horizontal -
                                  indicatorSize)),
                          top: (touchHeight / 2 - (indicatorSize / 2)),
                          child: Container(
                            width: indicatorSize,
                            height: indicatorSize,
                            decoration: BoxDecoration(
                              // color: config.indicatorColor,
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  Offset? initTouchPosition;
  double? initProgress;

  /// 保存触摸位置和当前进度
  void _saveTouch(Offset localPosition) {
    initTouchPosition = localPosition;
    initProgress = _progressController.progress;
  }

  /// 跳转到指定位置
  void _seekToPosition(Offset localPosition) {
    if (!_isInit) return;

    if (!_videoController.value.isInitialized ||
        _progressController.duration.inMilliseconds == 0 ||
        initTouchPosition == null ||
        initProgress == null) {
      return;
    }

    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final config =
        widget.progressBarConfig ?? SmartVideoProgressBarConfig.defaultConfig;

    var isDragging = _progressController.isDragging;
    var progressHeight = _computeProgressH(config.height, isDragging);
    var indicatorSize = _computeIndicatorSize(progressHeight);
    final progressBarWidth =
        renderBox.size.width - config.padding.horizontal - indicatorSize;

    // 计算拖拽距离
    final dragDistance = localPosition.dx - initTouchPosition!.dx;

    // 将拖拽距离转换为进度增量
    final progressDelta = dragDistance / progressBarWidth;

    // 基于初始进度和拖拽距离计算新进度
    final newProgress = (initProgress! + progressDelta).clamp(0.0, 1.0);

    final newPosition = Duration(
      milliseconds:
          (newProgress * _progressController.duration.inMilliseconds).round(),
    );

    _progressController.seekTo(newPosition);
  }

  void _onSeekEnd() {
    var position = _progressController.position;
    if (_isInit) {
      _videoController.seekTo(position);
    }
    _play();
  }

  @override
  void initState() {
    super.initState();
    _localController = widget.controller ?? SmartVideoPlayerController();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _initPlayer();
    });
  }

  @override
  void dispose() {
    if (_isInit) {
      _videoController.removeListener(videoListener);
      _videoController.dispose();
      _chewieController.dispose();
    }
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
                if (_isInit && _videoController.value.isInitialized != true)
                  Positioned.fill(
                    child: Image(
                      image: widget.coverImageProvider ??
                          NetworkImage(widget.cover ?? ""),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          SizedBox.shrink(),
                    ),
                  ),
                Positioned.fill(
                  child:
                      (_isInit && _videoController.value.isInitialized == true)
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
                          : (widget.showLoading
                              ? const Center(child: CircularProgressIndicator())
                              : SizedBox.shrink()),
                ),
                if (widget.clickPlay)
                  Positioned.fill(
                    child: GestureDetector(
                      child: Center(
                        child: (_isInit &&
                                    _videoController.value.isInitialized ==
                                        true) &&
                                (!_videoController.value.isPlaying) &&
                                _isManuallyPaused
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
                // 进度条
                if (_isInit &&
                    _videoController.value.isInitialized == true &&
                    (widget.progressBarConfig?.showProgressBar ?? true))
                  PositionedDirectional(
                    start: 0,
                    end: 0,
                    bottom: 0,
                    child: _buildProgressBar(),
                  ),
              ],
            ),
          );
        });
  }
}
