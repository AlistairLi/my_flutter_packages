import 'package:flutter/material.dart';
import 'package:photo_gallery_viewer/src/photo_gallery_viewer_base.dart';

/// 轮播图示例
class BannerViewExample extends StatelessWidget {
  final EdgeInsetsGeometry? margin;

  const BannerViewExample({super.key, this.margin});

  @override
  Widget build(BuildContext context) {
    var bannerData = <String>["xxx", "xxx"];
    Widget current = PhotoGalleryViewer<String>(
      dataList: bannerData,
      initialIndex: 0,
      infiniteScroll: true,
      height: 80,
      fit: BoxFit.cover,
      scale: 1.0,
      indicatorType: IndicatorType.dots,
      borderRadius: BorderRadius.circular(8),
      indicatorAlignment: Alignment.bottomCenter,
      imageUrlBuilder: (dynamic item) => (item as String),
    );
    if (margin != null) {
      current = Padding(
        padding: margin!,
        child: current,
      );
    }
    return current;
  }
}

/// 图片查看器示例
class GalleryViewPageExample extends StatelessWidget {
  final List<String> dataList;
  final int initialIndex;

  const GalleryViewPageExample({
    super.key,
    required this.dataList,
    required this.initialIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      extendBodyBehindAppBar: true,
      body: PhotoGalleryViewer<String>(
        dataList: dataList,
        initialIndex: initialIndex,
        scale: 1.0,
        indicatorType: IndicatorType.number,
        indicatorAlignment: Alignment.topCenter,
        enableZoom: true,
        isPage: true,
        imageUrlBuilder: (dynamic item) => (item as String),
      ),
    );
  }
}
