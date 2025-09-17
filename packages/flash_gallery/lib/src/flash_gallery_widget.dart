import 'dart:typed_data';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class FlashGalleryWidget extends StatelessWidget {
  /// 轮播图片列表, asset资源
  final List<String>? assets;

  /// 轮播图片列表, memory资源
  final List<Uint8List>? memoryImages;

  /// 可选宽度
  final double width;

  /// 可选高度
  final double height;

  /// 轮播间隔时间(毫秒)
  final int autoPlayIntervalMillis;

  /// 自动播放动画时间(毫秒)
  final int autoAnimationDurationMillis;

  /// 边框颜色
  final Color borderColor;

  /// 边框宽度
  final double borderWidth;

  /// 圆角
  final double radius;

  const FlashGalleryWidget({
    super.key,
    this.assets,
    this.memoryImages,
    this.autoPlayIntervalMillis = 3000,
    this.autoAnimationDurationMillis = 200,
    this.width = 220,
    this.height = 356,
    this.radius = 180,
    this.borderColor = Colors.lightBlue,
    this.borderWidth = 2,
  }) : assert(assets != null || memoryImages != null,
            "assets or memoryImages must not be null");

  @override
  Widget build(BuildContext context) {
    var length = assets?.length ?? memoryImages?.length ?? 0;
    return CarouselSlider(
      options: CarouselOptions(
        height: height,
        autoPlay: true,
        aspectRatio: width / height,
        enlargeCenterPage: true,
        initialPage: 0,
        autoPlayInterval: Duration(milliseconds: autoPlayIntervalMillis),
        scrollDirection: Axis.horizontal,
        enableInfiniteScroll: true,
        viewportFraction: 0.65,
        autoPlayAnimationDuration:
            Duration(milliseconds: autoAnimationDurationMillis),
        scrollPhysics: const NeverScrollableScrollPhysics(),
        pauseAutoPlayOnTouch: false,
      ),
      // carouselController: _carouselController,
      items: List.generate(length, (index) {
        Widget errorPlaceholder = Container(
          color: Colors.grey[200],
          child: Icon(
            Icons.error_outline,
            size: 40,
            color: Colors.grey,
          ),
        );
        Widget widget = SizedBox.shrink();
        if (assets != null) {
          widget = Image.asset(
            assets![index],
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return errorPlaceholder;
            },
          );
        } else if (memoryImages != null) {
          widget = Image.memory(
            memoryImages![index],
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return errorPlaceholder;
            },
          );
        }

        return Center(
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(
                color: borderColor,
                width: borderWidth,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(radius),
              child: widget,
            ),
          ),
        );
      }),
    );
  }
}
