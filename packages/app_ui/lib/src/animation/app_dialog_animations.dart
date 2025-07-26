import 'package:flutter/material.dart';

/// 常用弹窗动画封装
class AppDialogAnimations {
  AppDialogAnimations._();

  /// 淡入淡出动画
  static Widget fade({
    required Animation<double> animation,
    required Widget child,
  }) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }

  /// 底部弹出动画
  static Widget slideFromBottom({
    required Animation<double> animation,
    required Widget child,
  }) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOutCubic,
        ),
      ),
      child: child,
    );
  }

  /// 顶部弹出动画
  static Widget slideFromTop({
    required Animation<double> animation,
    required Widget child,
  }) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, -1),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOutCubic,
      )),
      child: child,
    );
  }

  /// 缩放弹出动画
  static Widget scale({
    required Animation<double> animation,
    required Widget child,
  }) {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.85, end: 1.0).animate(
        CurvedAnimation(
          parent: animation,
          curve: Curves.elasticOut,
        ),
      ),
      child: child,
    );
  }
}
