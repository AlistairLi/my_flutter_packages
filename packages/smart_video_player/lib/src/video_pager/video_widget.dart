import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:smart_video_player/smart_video_player.dart';
import 'package:smart_video_player/src/preload/file_cache_manager.dart';
import 'package:smart_video_player/src/video_pager/video_controller_manager.dart';
import 'package:video_player/video_player.dart';

class VideoWidget extends StatefulWidget {
  const VideoWidget({
    super.key,
    required this.videoItem,
    required this.index,
    this.overlayBuilder,
    this.showCover = true,
    this.coverImageProvider,
    this.fit = BoxFit.cover,
  });

  final VideoItem videoItem;

  final int index;

  final VideoOverlayBuilder? overlayBuilder;

  final bool showCover;

  final ImageProvider? coverImageProvider;

  final BoxFit fit;

  @override
  State<VideoWidget> createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget> {
  VideoPlayerController? _videoController;

  late VideoItem _item;
  late BoxFit _fit;

  final VideoControllerManager _controllerManager = VideoControllerManager();

  @override
  void initState() {
    super.initState();
    _item = widget.videoItem;
    _fit = widget.fit;
    _initializePlayer();
  }

  @override
  void dispose() {
    _controllerManager.unregisterController(widget.index, _videoController);
    _videoController?.removeListener(_videoListener);
    _videoController?.dispose();
    _videoController = null;
    super.dispose();
  }

  void _videoListener() {
    // 视频状态变化监听器
  }

  /// 初始化播放器
  Future<void> _initializePlayer() async {
    var path = _item.url;

    if (_item.sourceType == SmartVideoSourceType.file) {
      _videoController = VideoPlayerController.file(File(path));
    } else if (_item.sourceType == SmartVideoSourceType.network) {
      FileInfo? cacheFileInfo = await FileCacheManager().getFileFromCache(path);
      if (cacheFileInfo != null) {
        _videoController = VideoPlayerController.file(cacheFileInfo.file);
      } else {
        _videoController = VideoPlayerController.networkUrl(Uri.parse(path));
      }
    } else {
      _videoController = VideoPlayerController.asset(path);
    }

    // 注册控制器到管理器
    _controllerManager.registerController(widget.index, _videoController!);

    _videoController!.addListener(_videoListener);

    _videoController!
      ..setLooping(true)
      ..initialize().then((_) {
        if (mounted) {
          setState(() {});
          // 如果这是当前应该播放的视频，则开始播放
          // if (_controllerManager.currentPlayingIndex == widget.index) {
          //   _controllerManager.playVideo(widget.index);
          // }
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    Widget current = Stack(
      children: [
        if (widget.showCover)
          Positioned.fill(
            child: Image(
              image: widget.coverImageProvider ??
                  NetworkImage(_item.coverImage ?? ''),
              fit: _fit,
              errorBuilder: (context, error, stackTrace) {
                return SizedBox.shrink();
              },
            ),
          ),
        if (_videoController?.value.isInitialized == true)
          Positioned.fill(
            child: ClipRect(
              child: Container(
                width: double.infinity,
                height: double.infinity,
                child: FittedBox(
                  fit: widget.fit,
                  child: SizedBox(
                    width: _videoController!.value.size.width,
                    height: _videoController!.value.size.height,
                    child: VideoPlayer(_videoController!),
                  ),
                ),
              ),
            ),
          ),
        // Positioned.fill(
        //   child: ClipRRect(
        //     child: AspectRatio(
        //       aspectRatio: _videoController!.value.aspectRatio,
        //       child: FittedBox(
        //         fit: _fit,
        //         child: SizedBox(
        //           width: _videoController!.value.size.width,
        //           height: _videoController!.value.size.height,
        //           child: VideoPlayer(_videoController!),
        //         ),
        //       ),
        //     ),
        //   ),
        // ),
        if (widget.overlayBuilder != null)
          Positioned.fill(
            child: widget.overlayBuilder!(context, _item),
          ),
      ],
    );

    // if (widget.enableGesture) {
    //   current = GestureDetector(
    //     onTap: () {
    //       if (controller.value.isPlaying) {
    //         controller.pause();
    //       } else {
    //         controller.play();
    //       }
    //       setState(() {});
    //     },
    //     child: current,
    //   );
    // }
    return current;
  }
}
