import 'dart:async';

import 'package:app_ui/src/scroll/controller_listener/directional_scroll_controller_widget.dart';
import 'package:flutter/material.dart';

/// 高级 ScrollController 组件（带更多功能）
/// 🔶[UNTESTED]
class AdvancedScrollControllerWidget extends StatefulWidget {
  final Widget child;
  final Function(bool isScrolling)? onScrollStateChanged;
  final Function(ScrollDirection direction)? onScrollDirectionChanged;
  final Function(double offset, double maxScrollExtent)? onScrollProgress;
  final VoidCallback? onScrollStart;
  final VoidCallback? onScrollEnd;
  final VoidCallback? onScrollUpdate;
  final VoidCallback? onReachTop;
  final VoidCallback? onReachBottom;
  final Duration scrollEndDelay;
  final ScrollController? controller;
  final double topThreshold; // 到达顶部的阈值
  final double bottomThreshold; // 到达底部的阈值

  const AdvancedScrollControllerWidget({
    super.key,
    required this.child,
    this.onScrollStateChanged,
    this.onScrollDirectionChanged,
    this.onScrollProgress,
    this.onScrollStart,
    this.onScrollEnd,
    this.onScrollUpdate,
    this.onReachTop,
    this.onReachBottom,
    this.scrollEndDelay = const Duration(milliseconds: 150),
    this.controller,
    this.topThreshold = 0.0,
    this.bottomThreshold = 0.0,
  });

  @override
  State<AdvancedScrollControllerWidget> createState() =>
      _AdvancedScrollControllerWidgetState();
}

class _AdvancedScrollControllerWidgetState
    extends State<AdvancedScrollControllerWidget> {
  late ScrollController _scrollController;
  bool _isScrolling = false;
  ScrollDirection _currentDirection = ScrollDirection.none;
  double _lastScrollOffset = 0;
  Timer? _scrollTimer;
  bool _hasReachedTop = false;
  bool _hasReachedBottom = false;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.controller ?? ScrollController();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final position = _scrollController.position;
    final currentOffset = position.pixels;
    final maxScrollExtent = position.maxScrollExtent;

    // 检测滚动方向
    ScrollDirection newDirection = ScrollDirection.none;
    if (currentOffset > _lastScrollOffset) {
      newDirection = ScrollDirection.down;
    } else if (currentOffset < _lastScrollOffset) {
      newDirection = ScrollDirection.up;
    }

    // 方向变化回调
    if (newDirection != _currentDirection) {
      // setState(() {
      _currentDirection = newDirection;
      // });
      widget.onScrollDirectionChanged?.call(newDirection);
    }

    // 滚动进度回调
    widget.onScrollProgress?.call(currentOffset, maxScrollExtent);

    // 检测到达顶部
    if (currentOffset <= widget.topThreshold && !_hasReachedTop) {
      _hasReachedTop = true;
      widget.onReachTop?.call();
    } else if (currentOffset > widget.topThreshold) {
      _hasReachedTop = false;
    }

    // 检测到达底部
    if (currentOffset >= maxScrollExtent - widget.bottomThreshold &&
        !_hasReachedBottom) {
      _hasReachedBottom = true;
      widget.onReachBottom?.call();
    } else if (currentOffset < maxScrollExtent - widget.bottomThreshold) {
      _hasReachedBottom = false;
    }

    // 滚动状态处理
    if (!_isScrolling) {
      // setState(() {
      _isScrolling = true;
      // });
      widget.onScrollStateChanged?.call(true);
      widget.onScrollStart?.call();
    }

    // 重置定时器
    _scrollTimer?.cancel();
    _scrollTimer = Timer(widget.scrollEndDelay, () {
      if (mounted) {
        // setState(() {
        _isScrolling = false;
        _currentDirection = ScrollDirection.none;
        // });
        widget.onScrollStateChanged?.call(false);
        widget.onScrollDirectionChanged?.call(ScrollDirection.none);
        widget.onScrollEnd?.call();
      }
    });

    widget.onScrollUpdate?.call();
    _lastScrollOffset = currentOffset;
  }

  @override
  void dispose() {
    _scrollTimer?.cancel();
    if (widget.controller == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  ScrollController get controller => _scrollController;
}
