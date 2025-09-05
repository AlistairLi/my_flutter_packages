import 'package:flash_gallery/flash_gallery.dart';
import 'package:flutter/material.dart';

class FlashGalleryExamplePage extends StatelessWidget {
  const FlashGalleryExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flash Gallery'),
      ),
      body: Center(
        child: FlashCarouselExampleWidget(
          duration: 2000,
          autoAnimationDuration: 400,
        ),
      ),
    );
  }
}

/// 轮播图Widget
class FlashCarouselExampleWidget extends StatelessWidget {
  final int duration; // 轮播间隔时间
  final int autoAnimationDuration; // 自动播放动画时间

  FlashCarouselExampleWidget({
    super.key,
    required this.duration,
    this.autoAnimationDuration = 200,
  });

  final _imgList = [
    "assets/img_1.jpg",
    "assets/img_2.jpg",
    "assets/img_3.jpg",
  ];

  @override
  Widget build(BuildContext context) {
    var assetsList = _imgList;
    if (assetsList.isEmpty) return const SizedBox.shrink();
    return Center(
      child: FlashGalleryWidget(
        assets: assetsList,
        width: 220,
        height: 360,
        autoPlayIntervalMillis: duration,
        autoAnimationDurationMillis: autoAnimationDuration,
        radius: 200,
        borderColor: Colors.yellow,
      ),
    );
  }
}
