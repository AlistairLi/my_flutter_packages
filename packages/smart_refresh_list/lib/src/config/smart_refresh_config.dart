import 'package:flutter/material.dart';

/// 刷新配置类
class RefreshConfig {
  static const int defaultPageSize = 20;
  static const Duration defaultDuration = Duration(milliseconds: 300);
  static const Duration defaultAnimationDuration = Duration(milliseconds: 200);

  /// 获取主题色彩方案
  static ColorScheme scheme(BuildContext context) =>
      Theme.of(context).colorScheme;

  /// 默认刷新配置
  static RefreshStyleConfig get defaultStyleConfig =>
      const RefreshStyleConfig();
}

/// 刷新样式配置
class RefreshStyleConfig {
  final Color primaryColor;
  final Color backgroundColor;
  final double headerHeight;
  final double footerHeight;
  final Duration animationDuration;
  final bool enableOverScroll;

  const RefreshStyleConfig({
    this.primaryColor = Colors.blue,
    this.backgroundColor = Colors.transparent,
    this.headerHeight = 60.0,
    this.footerHeight = 60.0,
    this.animationDuration = RefreshConfig.defaultAnimationDuration,
    this.enableOverScroll = true,
  });

  RefreshStyleConfig copyWith({
    Color? primaryColor,
    Color? backgroundColor,
    double? headerHeight,
    double? footerHeight,
    Duration? animationDuration,
    bool? enableOverScroll,
  }) {
    return RefreshStyleConfig(
      primaryColor: primaryColor ?? this.primaryColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      headerHeight: headerHeight ?? this.headerHeight,
      footerHeight: footerHeight ?? this.footerHeight,
      animationDuration: animationDuration ?? this.animationDuration,
      enableOverScroll: enableOverScroll ?? this.enableOverScroll,
    );
  }
}
