import 'package:flutter/material.dart';

/// 滚动监听组件
/// 🔶[UNTESTED]
class ScrollListenerWidget extends StatelessWidget {
  final Widget child;
  final Function(bool isScrolling)? onScrollStateChanged;
  final VoidCallback? onScrollStart;
  final VoidCallback? onScrollEnd;
  final VoidCallback? onScrollUpdate;

  /// 是否拦截事件
  final bool shouldInterceptEvents;

  const ScrollListenerWidget({
    super.key,
    required this.child,
    this.onScrollStateChanged,
    this.onScrollStart,
    this.onScrollEnd,
    this.onScrollUpdate,
    this.shouldInterceptEvents = false,
  });

  bool _onScrollNotification(ScrollNotification notification) {
    if (notification is ScrollStartNotification) {
      onScrollStateChanged?.call(true);
      onScrollStart?.call();
    } else if (notification is ScrollEndNotification) {
      onScrollStateChanged?.call(false);
      onScrollEnd?.call();
    } else if (notification is ScrollUpdateNotification) {
      onScrollUpdate?.call();
    }
    return shouldInterceptEvents;
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: _onScrollNotification,
      child: child,
    );
  }
}
