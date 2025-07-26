import 'dart:async';

import 'package:flutter/material.dart';

enum ScrollDirection {
  none,
  up,
  down,
}

/// 带滚动方向的 ScrollController 监听组件
/// 🔶[UNTESTED]
class DirectionalScrollControllerWidget extends StatefulWidget {
  final Widget child;
  final Function(ScrollDirection direction)? onScrollDirectionChanged;
  final Function(bool isScrolling)? onScrollStateChanged;
  final VoidCallback? onScrollStart;
  final VoidCallback? onScrollEnd;
  final VoidCallback? onScrollUpdate;
  final Duration scrollEndDelay;
  final ScrollController? controller;

  const DirectionalScrollControllerWidget({
    super.key,
    required this.child,
    this.onScrollDirectionChanged,
    this.onScrollStateChanged,
    this.onScrollStart,
    this.onScrollEnd,
    this.onScrollUpdate,
    this.scrollEndDelay = const Duration(milliseconds: 150),
    this.controller,
  });

  @override
  State<DirectionalScrollControllerWidget> createState() =>
      _DirectionalScrollControllerWidgetState();
}

class _DirectionalScrollControllerWidgetState
    extends State<DirectionalScrollControllerWidget> {
  late ScrollController _scrollController;
  bool _isScrolling = false;
  ScrollDirection _currentDirection = ScrollDirection.none;
  double _lastScrollOffset = 0;
  Timer? _scrollTimer;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.controller ?? ScrollController();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final currentOffset = _scrollController.offset;

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
