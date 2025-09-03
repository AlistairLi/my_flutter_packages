import 'package:flutter/material.dart';

/// 圆点指示器样式配置
class DotsIndicatorStyle {
  /// 激活状态颜色
  final Color activeColor;

  /// 非激活状态颜色
  final Color inactiveColor;

  /// 激活状态大小
  final Size activeSize;

  /// 非激活状态大小
  final Size inactiveSize;

  /// 激活状态形状
  final ShapeBorder activeShape;

  /// 非激活状态形状
  final ShapeBorder inactiveShape;

  /// 间距
  final double spacing;

  /// 垂直偏移
  final double verticalOffset;

  const DotsIndicatorStyle({
    this.activeColor = Colors.white,
    this.inactiveColor = const Color(0x80FFFFFF),
    this.activeSize = const Size(8, 8),
    this.inactiveSize = const Size(6, 6),
    this.activeShape = const CircleBorder(),
    this.inactiveShape = const CircleBorder(),
    this.spacing = 8.0,
    this.verticalOffset = 0.0,
  });

  /// 创建圆角矩形样式的指示器
  factory DotsIndicatorStyle.rounded({
    Color activeColor = Colors.white,
    Color inactiveColor = const Color(0x80FFFFFF),
    double activeSize = 8.0,
    double inactiveSize = 6.0,
    double borderRadius = 4.0,
    double spacing = 8.0,
    double verticalOffset = 0.0,
  }) {
    return DotsIndicatorStyle(
      activeColor: activeColor,
      inactiveColor: inactiveColor,
      activeSize: Size(activeSize, activeSize),
      inactiveSize: Size(inactiveSize, inactiveSize),
      activeShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      inactiveShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      spacing: spacing,
      verticalOffset: verticalOffset,
    );
  }

  /// 创建圆形样式的指示器
  factory DotsIndicatorStyle.circular({
    Color activeColor = Colors.white,
    Color inactiveColor = const Color(0x80FFFFFF),
    double activeSize = 8.0,
    double inactiveSize = 6.0,
    double spacing = 8.0,
    double verticalOffset = 0.0,
  }) {
    return DotsIndicatorStyle(
      activeColor: activeColor,
      inactiveColor: inactiveColor,
      activeSize: Size(activeSize, activeSize),
      inactiveSize: Size(inactiveSize, inactiveSize),
      activeShape: const CircleBorder(),
      inactiveShape: const CircleBorder(),
      spacing: spacing,
      verticalOffset: verticalOffset,
    );
  }
}
