import 'package:flutter/material.dart';

/// 背景组件
///
/// 一个可复用的背景组件，支持渐变色背景和重复平铺的图像纹理，
/// 通常用于应用的整体背景或页面背景区域
class AppBackground extends StatelessWidget {
  /// 背景图像资源路径
  final String assetName;

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

  const AppBackground({
    super.key,
    required this.assetName,
    required this.child,
    this.begin = Alignment.topCenter,
    this.end = Alignment.bottomCenter,
    this.colors = const [Color(0xFFF5F5F5), Color(0xFFF5F5F5)],
    this.stops,
    this.position = DecorationPosition.background,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: begin,
          end: end,
          colors: colors,
          stops: stops,
        ),
        image: DecorationImage(
          image: AssetImage(assetName),
          fit: BoxFit.contain,
          repeat: ImageRepeat.repeat,
        ),
      ),
      position: position,
      child: child,
    );
  }
}
