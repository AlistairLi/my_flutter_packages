import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:smart_video_player/smart_video_player.dart';
import 'package:visibility_detector_widget/visibility_detector_widget.dart';

class VideoPager extends StatefulWidget {
  const VideoPager({
    super.key,
    required this.items,
    this.initialPage = 0,
    this.controller,
    this.overlayBuilder,
    this.showCover = true,
    this.coverImageBuilder,
    this.fit = BoxFit.cover,
    this.preloadCount = 1,
    this.keepRange = 1,
    this.preloadToLocal = true,
    this.onPageChanged,
  });

  final List<VideoItem> items;

  /// 初始页面索引，默认为 0
  final int initialPage;

  final VideoPagerController? controller;

  final VideoOverlayBuilder? overlayBuilder;

  final bool showCover;

  final ImageProvider Function(int index, VideoItem item)? coverImageBuilder;

  final BoxFit fit;

  final int preloadCount;

  final int keepRange;

  /// 是否预加载视频到本地，默认为true
  final bool preloadToLocal;

  final void Function(int index, VideoItem item)? onPageChanged;

  @override
  State<VideoPager> createState() => _VideoPagerState();
}

class _VideoPagerState extends State<VideoPager> {
  final CarouselSliderController carouselSliderController =
      CarouselSliderController();

  late List<VideoItem> _items;
  late int _initialPage;
  late int _currentIndex;

  bool _isVisible = false;

  /// 视频预加载管理器
  final VideoPreloadManager _videoPreloadManager = VideoPreloadManager();

  final VideoControllerManager _controllerManager = VideoControllerManager();

  @override
  void initState() {
    super.initState();
    _items = widget.items;
    _initialPage = widget.initialPage;
    _currentIndex = _initialPage;
    _controllerManager.setCurrentPlayingIndex(_currentIndex);

    _initExternalController();

    preloadAdjacentVideos(0, _items);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _initExternalController() {
    if (widget.controller == null) return;

    widget.controller!.play = () {
      if (_isVisible) {
        _controllerManager.playVideo(_currentIndex);
      }
    };

    widget.controller!.pause = () {
      _controllerManager.pauseAll();
    };

    widget.controller!.nextPage = () {
      carouselSliderController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    };

    widget.controller!.previousPage = () {
      carouselSliderController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    };

    widget.controller!.jumpToRealIndex = (index) {
      carouselSliderController.jumpToPage(index);
    };
  }

  void _onPageChanged(int index) {
    _currentIndex = index;
    _controllerManager.setCurrentPlayingIndex(_currentIndex);

    // 播放当前页面视频
    _controllerManager.playVideo(_currentIndex);

    if (widget.onPageChanged != null) {
      widget.onPageChanged!(index, widget.items[index]);
    }

    // 预加载相邻视频到本地
    preloadAdjacentVideos(index, _items);
    // 清理远离当前位置的视频缓存
    cleanupDistantVideos(index, _items);
  }

  /// 预加载相邻视频
  ///
  /// [currentIndex] 当前视频索引
  /// [mediaList] 媒体列表
  Future<void> preloadAdjacentVideos(
      int currentIndex, List<VideoItem> mediaList) async {
    // 如果不启用预加载到本地，则直接返回
    if (!widget.preloadToLocal) return;
    if (mediaList.isEmpty) return;
    var list = List<VideoItem>.from(mediaList);

    // 获取所有媒体项URL
    final allUrls = list
        .map((element) => element.url)
        .where((element) => element.isNotEmpty)
        .cast<String>()
        .toList();

    var currentUrl = list[currentIndex].url;

    // 调用预加载管理器
    await _videoPreloadManager.preloadAdjacentVideosFromMixedList(
      currentMediaUrl: currentUrl,
      allMediaUrls: allUrls,
      videoUrls: allUrls,
      preloadCount: widget.preloadCount,
    );

    // 打印队列状态（用于调试）
    _videoPreloadManager.printQueueStatus();
  }

  /// 清理远离当前位置的视频缓存
  ///
  /// [currentIndex] 当前视频索引
  /// [mediaList] 媒体列表
  void cleanupDistantVideos(int currentIndex, List<VideoItem> mediaList) {
    // 如果不启用预加载到本地，则直接返回
    if (!widget.preloadToLocal) return;
    if (mediaList.isEmpty) return;
    var list = List<VideoItem>.from(mediaList);

    // 获取所有媒体项URL
    final allUrls = list
        .map((element) => element.url)
        .where((element) => element.isNotEmpty)
        .cast<String>()
        .toList();

    var currentUrl = list[currentIndex].url;

    // 清理远离当前位置的缓存
    _videoPreloadManager.cleanupDistantCache(
      currentMediaUrl: currentUrl,
      allMediaUrls: allUrls,
      videoUrls: allUrls,
      keepRange: widget.keepRange,
    );
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetectorWidget(
      key: Key(hashCode.toString() + DateTime.now().toString()),
      onVisible: () {
        _isVisible = true;
        _controllerManager.playVideo(_currentIndex, retryCount: 3);
      },
      onInvisible: () {
        _isVisible = false;
        _controllerManager.pauseAll();
      },
      child: CarouselSlider.builder(
        itemCount: _items.length,
        itemBuilder: (context, i, realIndex) {
          var item = _items[i];
          return VideoWidget(
            videoItem: item,
            index: i,
            fit: widget.fit,
            showCover: widget.showCover,
            coverImageProvider: widget.coverImageBuilder?.call(i, item),
            overlayBuilder: (context, item, {index}) {
              return widget.overlayBuilder?.call(context, item, index: i) ??
                  Container();
            },
          );
        },
        carouselController: carouselSliderController,
        options: CarouselOptions(
          height: double.infinity,
          initialPage: _initialPage,
          viewportFraction: 1.0,
          disableCenter: false,
          onPageChanged: (index, reason) => _onPageChanged(index),
        ),
      ),
    );
  }
}
