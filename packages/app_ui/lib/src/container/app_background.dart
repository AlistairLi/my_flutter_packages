import 'package:flutter/material.dart';

/// 背景组件
///
/// 一个可复用的背景组件，支持渐变色背景和重复平铺的图像纹理，
/// 通常用于应用的整体背景或页面背景区域
class AppBackground extends StatelessWidget {
  /// 背景图像资源路径
  final String? assetName;

  /// 背景图片资源
  final ImageProvider? imageProvider;

  /// 渐变起始位置，默认为顶部中心
  final AlignmentGeometry begin;

  /// 渐变结束位置，默认为底部中心
  final AlignmentGeometry end;

  /// 渐变颜色列表，默认为两个相同的浅灰色
  final List<Color> colors;

  /// 渐变颜色的位置停止点，可选参数
  final List<double>? stops;

  /// 子组件，背景之上的内容
  final Widget child;

  /// 背景位置，可选参数，默认为背景
  final DecorationPosition position;

  /// 背景的圆角，可选参数，默认为无圆角
  final BorderRadiusGeometry? borderRadius;

  /// 背景的阴影，可选参数，默认为无阴影
  final List<BoxShadow>? boxShadow;

  /// 纹理图片的重复方式
  final ImageRepeat repeat;

  /// 纹理图片的缩放倍率，值越大纹理越细
  final double imageScale;

  /// 纹理图片的缩放方式
  final BoxFit imageFit;

  /// 纹理图片的采样质量
  final FilterQuality filterQuality;

  /// 纹理图片的不透明度（0~1），值越小纹理越细腻
  final double imageOpacity;

  const AppBackground({
    super.key,
    required this.child,
    this.assetName,
    this.imageProvider,
    this.begin = Alignment.topCenter,
    this.end = Alignment.bottomCenter,
    this.colors = const [Color(0xFFF5F5F5), Color(0xFFF5F5F5)],
    this.stops,
    this.position = DecorationPosition.background,
    this.repeat = ImageRepeat.repeat,
    this.borderRadius,
    this.boxShadow,
    this.imageScale = 1.0,
    this.imageFit = BoxFit.none,
    this.filterQuality = FilterQuality.none,
    this.imageOpacity = 1.0,
  }) : assert(
          assetName != null || imageProvider != null,
          'assetName and imageProvider cannot both be null',
        );

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        gradient: LinearGradient(
          begin: begin,
          end: end,
          colors: colors,
          stops: stops,
        ),
        boxShadow: boxShadow,
        image: DecorationImage(
          image: imageProvider ?? AssetImage(assetName!),
          fit: imageFit,
          repeat: repeat,
          scale: imageScale,
          filterQuality: filterQuality,
          colorFilter: imageOpacity >= 1.0
              ? null
              : ColorFilter.matrix([
                  1,
                  0,
                  0,
                  0,
                  0,
                  0,
                  1,
                  0,
                  0,
                  0,
                  0,
                  0,
                  1,
                  0,
                  0,
                  0,
                  0,
                  0,
                  imageOpacity,
                  0,
                ]),
        ),
      ),
      position: position,
      child: child,
    );
  }
}
