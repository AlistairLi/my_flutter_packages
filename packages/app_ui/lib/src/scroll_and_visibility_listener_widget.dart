import 'package:app_ui/src/scroll/controller_listener/scroll_controller_listener_widget.dart';
import 'package:app_ui/src/visibility/visibility_listener_widget.dart';
import 'package:flutter/material.dart';

/// 列表滚动和可见性监听器
///
/// 功能：
/// - 监听列表是否在滚动
/// - 监听界面是否可见
/// - 监听是否切换到后台
class ScrollAndVisibilityListenerWidget extends StatelessWidget {
  final Widget child;
  final ScrollController? controller;

  /// 监听可见性状态的key
  final String visibilityKey;
  final void Function(bool isScrolling)? onScrollStateChanged;
  final void Function(bool isVisible, bool isInForeground)? onVisibilityChanged;

  const ScrollAndVisibilityListenerWidget({
    super.key,
    required this.child,
    required this.visibilityKey,
    this.controller,
    this.onScrollStateChanged,
    this.onVisibilityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ScrollControllerListenerWidget(
      controller: controller,
      onScrollStateChanged: onScrollStateChanged,
      child: VisibilityListenerWidget(
        child: child,
        visibilityKey: visibilityKey,
        onStateChanged: onVisibilityChanged,
      ),
    );
  }
}
