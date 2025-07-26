import 'package:flutter/material.dart';

enum ScrollDirection {
  none,
  up,
  down,
}

/// 带滚动方向的监听滚动状态组件
/// 🔶[UNTESTED]
class DirectionalScrollListenerWidget extends StatefulWidget {
  final Widget child;
  final Function(ScrollDirection direction)? onScrollDirectionChanged;
  final Function(bool isScrolling)? onScrollStateChanged;
  final VoidCallback? onScrollStart;
  final VoidCallback? onScrollEnd;
  final bool shouldInterceptEvents; //是否拦截事件

  const DirectionalScrollListenerWidget({
    super.key,
    required this.child,
    this.onScrollDirectionChanged,
    this.onScrollStateChanged,
    this.onScrollStart,
    this.onScrollEnd,
    this.shouldInterceptEvents = false,
  });

  @override
  State<DirectionalScrollListenerWidget> createState() =>
      _DirectionalScrollListenerWidgetState();
}

class _DirectionalScrollListenerWidgetState
    extends State<DirectionalScrollListenerWidget> {
  // bool _isScrolling = false;
  ScrollDirection _currentDirection = ScrollDirection.none;
  double _lastScrollOffset = 0;

  bool _onScrollNotification(ScrollNotification notification) {
    if (notification is ScrollStartNotification) {
      _handleScrollStart();
    } else if (notification is ScrollEndNotification) {
      _handleScrollEnd();
    } else if (notification is ScrollUpdateNotification) {
      _handleScrollUpdate(notification.metrics.pixels);
    }
    return widget.shouldInterceptEvents;
  }

  void _handleScrollStart() {
    // if (!_isScrolling) {
    //   _isScrolling = true;
    widget.onScrollStateChanged?.call(true);
    widget.onScrollStart?.call();
    // }
  }

  void _handleScrollEnd() {
    // _isScrolling = false;
    _currentDirection = ScrollDirection.none;
    widget.onScrollStateChanged?.call(false);
    widget.onScrollDirectionChanged?.call(ScrollDirection.none);
    widget.onScrollEnd?.call();
  }

  void _handleScrollUpdate(double currentOffset) {
    ScrollDirection newDirection = ScrollDirection.none;

    if (currentOffset > _lastScrollOffset) {
      newDirection = ScrollDirection.down;
    } else if (currentOffset < _lastScrollOffset) {
      newDirection = ScrollDirection.up;
    }

    if (newDirection != _currentDirection) {
      _currentDirection = newDirection;
      widget.onScrollDirectionChanged?.call(newDirection);
    }

    _lastScrollOffset = currentOffset;
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: _onScrollNotification,
      child: widget.child,
    );
  }
}
