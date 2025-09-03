import 'dart:io';
import 'dart:math';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:photo_gallery_viewer/src/dots_indicator_style.dart';
import 'package:photo_view/photo_view.dart';

/// 图片查看器
/// 功能
///  · 左右滑动
///  · 缩放/点击
///  · 指示器
class PhotoGalleryViewer<T> extends StatefulWidget {
  /// 组件宽度
  final double? width;

  /// 组件高度
  final double? height;

  /// 数据列表
  final List<T> dataList;

  /// 获取图片路径的闭包函数
  /// 注意：这里 item 用不了泛型, 使用时需要 item as T
  final String Function(dynamic item) imageUrlBuilder;

  /// 自定义图片提供者，如果不提供则根据路径自动判断
  final ImageProvider Function(String imageUrl)? imageProviderBuilder;

  /// 初始显示的图片索引
  final int initialIndex;

  /// 是否支持无限滑动
  final bool infiniteScroll;

  /// 是否支持缩放
  final bool enableZoom;

  /// 图片点击回调
  final void Function(int index, dynamic item)? onImageTap;

  /// 图片切换回调
  final void Function(int index, T item)? onPageChanged;

  /// 是否为页面
  final bool isPage;

  /// 指示器类型
  final IndicatorType indicatorType;

  /// 指示器位置
  final AlignmentGeometry indicatorAlignment;

  /// 指示器边距
  final EdgeInsetsGeometry? indicatorMargin;

  /// 数字指示器样式
  final TextStyle? numberIndicatorStyle;

  /// 圆点指示器样式
  final DotsIndicatorStyle? dotsIndicatorStyle;

  /// 是否显示指示器
  final bool showIndicator;

  /// 图片加载占位符
  final Widget? placeholder;

  /// 图片加载错误占位符
  final Widget? errorWidget;

  /// 图片适配方式
  final BoxFit fit;

  /// 尺寸缩放因子，默认为1.0（不缩放）
  final double scale;

  /// 整个组件的圆角配置
  final BorderRadius? borderRadius;

  /// 图片的圆角配置（仅在非缩放模式下生效）
  final BorderRadius? imageBorderRadius;

  /// 自定义圆点指示器构建器
  final Widget Function(BuildContext context, int currentIndex, int dotsCount)?
      dotsIndicatorBuilder;

  /// 自定义数字指示器构建器
  final Widget Function(BuildContext context, int currentIndex, int totalCount)?
      numberIndicatorBuilder;

  const PhotoGalleryViewer({
    super.key,
    required this.dataList,
    required this.imageUrlBuilder,
    required this.scale,
    this.imageProviderBuilder,
    this.width,
    this.height,
    this.initialIndex = 0,
    this.infiniteScroll = false,
    this.enableZoom = false,
    this.onImageTap,
    this.onPageChanged,
    this.isPage = false,
    this.indicatorType = IndicatorType.dots,
    this.indicatorAlignment = AlignmentDirectional.bottomCenter,
    this.indicatorMargin,
    this.numberIndicatorStyle,
    this.dotsIndicatorStyle,
    this.showIndicator = true,
    this.placeholder,
    this.errorWidget,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.imageBorderRadius,
    this.dotsIndicatorBuilder,
    this.numberIndicatorBuilder,
  });

  @override
  State<PhotoGalleryViewer> createState() => _PhotoGalleryViewerState();
}

class _PhotoGalleryViewerState<T> extends State<PhotoGalleryViewer<T>> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget content = SizedBox(
      width: widget.width,
      height: widget.height,
      child: Stack(
        children: [
          // 图片查看器主体
          _buildImageViewer(),

          // 指示器
          if (widget.showIndicator && widget.dataList.length > 1)
            _buildIndicator(),
        ],
      ),
    );

    // 应用整个组件的圆角
    if (widget.borderRadius != null) {
      content = ClipRRect(
        borderRadius: widget.borderRadius!,
        child: content,
      );
    }

    return content;
  }

  /// 构建图片查看器主体
  Widget _buildImageViewer() {
    if (widget.infiniteScroll && widget.dataList.length > 1) {
      return _buildCarouselSlider();
    } else {
      return _buildPageView();
    }
  }

  /// 使用CarouselSlider实现无限滑动
  Widget _buildCarouselSlider() {
    return CarouselSlider.builder(
      itemCount: widget.dataList.length,
      itemBuilder: (context, index, realIndex) {
        return _buildImageItem(widget.dataList[index], index);
      },
      options: CarouselOptions(
        height: widget.height ?? double.infinity,
        viewportFraction: 1.0,
        initialPage: widget.initialIndex,
        enableInfiniteScroll: true,
        disableCenter: true,
        onPageChanged: (index, reason) {
          setState(() {
            _currentIndex = index;
          });
          widget.onPageChanged?.call(index, widget.dataList[index]);
        },
      ),
    );
  }

  /// 使用PageView实现有限滑动
  Widget _buildPageView() {
    return PageView.builder(
      controller: _pageController,
      itemCount: widget.dataList.length,
      onPageChanged: (index) {
        setState(() {
          _currentIndex = index;
        });
        widget.onPageChanged?.call(index, widget.dataList[index]);
      },
      itemBuilder: (context, index) {
        return _buildImageItem(widget.dataList[index], index);
      },
    );
  }

  /// 构建单个图片项
  Widget _buildImageItem(T item, int index) {
    final imageUrl = widget.imageUrlBuilder(item);
    final imageProvider = _getImageProvider(imageUrl);
    if (widget.enableZoom) {
      return _buildZoomableImage(imageProvider, index, item);
    } else {
      return _buildNormalImage(imageProvider, index, item);
    }
  }

  /// 获取图片提供者
  ImageProvider _getImageProvider(String imageUrl) {
    // 如果提供了自定义图片提供者，则使用自定义的
    if (widget.imageProviderBuilder != null) {
      return widget.imageProviderBuilder!(imageUrl);
    }

    // 否则根据路径自动判断
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return NetworkImage(imageUrl);
    } else if (imageUrl.startsWith('assets/') ||
        imageUrl.startsWith('asset:')) {
      return AssetImage(imageUrl);
    } else if (imageUrl.startsWith('file://')) {
      return FileImage(File(Uri.parse(imageUrl).toFilePath()));
    } else if (imageUrl.startsWith('/')) {
      return FileImage(File(imageUrl));
    } else {
      return AssetImage(imageUrl);
    }
  }

  /// 构建可缩放的图片
  Widget _buildZoomableImage(ImageProvider imageProvider, int index, T item) {
    return PhotoView(
      imageProvider: imageProvider,
      errorBuilder: (context, error, stackTrace) {
        return widget.errorWidget ??
            const Center(
              child: Icon(Icons.error, color: Colors.red),
            );
      },
      minScale: PhotoViewComputedScale.contained,
      maxScale: PhotoViewComputedScale.covered * 2.0,
      initialScale: PhotoViewComputedScale.contained,
      onTapUp: (details, controllerValue, controller) {
        widget.onImageTap?.call(index, item);
      },
    );
  }

  /// 构建不可缩放图片
  Widget _buildNormalImage(ImageProvider imageProvider, int index, T item) {
    Widget imageWidget = Image(
      image: imageProvider,
      fit: widget.fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return widget.placeholder ??
            const Center(
              child: CircularProgressIndicator(),
            );
      },
      errorBuilder: (context, error, stackTrace) {
        return widget.errorWidget ??
            const Center(
              child: Icon(Icons.error, color: Colors.red),
            );
      },
    );

    // 应用图片圆角（仅在非缩放模式下）
    if (widget.imageBorderRadius != null) {
      imageWidget = ClipRRect(
        borderRadius: widget.imageBorderRadius!,
        child: imageWidget,
      );
    }

    return GestureDetector(
      onTap: () {
        widget.onImageTap?.call(index, item);
      },
      behavior: HitTestBehavior.opaque,
      child: imageWidget,
    );
  }

  /// 构建指示器
  Widget _buildIndicator() {
    Widget indicator;

    if (widget.isPage &&
        (widget.indicatorAlignment == Alignment.topCenter ||
            widget.indicatorAlignment == AlignmentDirectional.topCenter)) {
      var statusBarHeightPixel =
          MediaQuery.of(context).padding.top - kToolbarHeight;
      indicator = Container(
        height: kToolbarHeight,
        alignment: Alignment.center,
        margin: EdgeInsets.only(top: max(statusBarHeightPixel, 0)),
        child: widget.indicatorType == IndicatorType.dots
            ? _buildDotsIndicator()
            : _buildNumberIndicator(),
      );
    } else {
      switch (widget.indicatorType) {
        case IndicatorType.dots:
          indicator = _buildDotsIndicator();
          break;
        case IndicatorType.number:
          indicator = _buildNumberIndicator();
          break;
      }
      indicator = Align(
        alignment: widget.indicatorAlignment,
        child: Container(
          margin: widget.indicatorMargin ??
              EdgeInsetsDirectional.symmetric(
                horizontal: 30 * widget.scale,
                vertical: 10 * widget.scale,
              ),
          child: indicator,
        ),
      );
    }

    // 可添加背景色

    return indicator;
  }

  /// 构建圆点指示器
  Widget _buildDotsIndicator() {
    // 使用自定义构建器（如果提供）
    if (widget.dotsIndicatorBuilder != null) {
      return widget.dotsIndicatorBuilder!(
        context,
        _currentIndex,
        widget.dataList.length,
      );
    }

    // 可添加圆点指示器的由外部配置
    return SizedBox(
      height: 16 * widget.scale,
      child: DotsIndicator(
        dotsCount: widget.dataList.length,
        position: _currentIndex.toDouble(),
        decorator: DotsDecorator(
          activeColor: Colors.white,
          activeSize: const Size(6, 6),
          activeShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          size: Size(6, 6),
          color: Colors.white54,
          spacing: EdgeInsets.all(4),
        ),
      ),
    );
  }

  /// 构建数字指示器
  Widget _buildNumberIndicator() {
    // 使用自定义构建器（如果提供）
    if (widget.numberIndicatorBuilder != null) {
      return widget.numberIndicatorBuilder!(
        context,
        _currentIndex,
        widget.dataList.length,
      );
    }

    return Text(
      '${_currentIndex + 1}/${widget.dataList.length}',
      style: widget.numberIndicatorStyle ??
          TextStyle(
            color: Colors.white,
            fontSize: 14 * widget.scale,
            fontWeight: FontWeight.w500,
          ),
    );
  }
}

/// 指示器类型
enum IndicatorType {
  /// 圆点指示器
  dots,

  /// 数字指示器
  number,
}
