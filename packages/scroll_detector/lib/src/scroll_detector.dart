import 'dart:async';

import 'package:flutter/material.dart';

/// 滚动监听Widget
class ScrollDetector extends StatefulWidget {
  final Widget child;
  final void Function(double offset, double viewportDimension)? onScrollStart;
  final void Function(double offset, double viewportDimension)? onScrollEnd;
  final VoidCallback? onScrollUpdate;
  final Duration scrollEndDelay;
  final ScrollController? controller;

  const ScrollDetector({
    super.key,
    required this.child,
    this.onScrollStart,
    this.onScrollEnd,
    this.onScrollUpdate,
    this.scrollEndDelay = const Duration(milliseconds: 200),
    this.controller,
  });

  @override
  State<ScrollDetector> createState() => _ScrollDetectorState();
}

class _ScrollDetectorState extends State<ScrollDetector> {
  late ScrollController _scrollController;
  bool _isScrolling = false;
  Timer? _scrollTimer;

  ScrollController get controller => _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.controller ?? ScrollController();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_isScrolling) {
      _isScrolling = true;
      var offset = 0.0;
      var viewportDimension = 0.0;
      if (_scrollController.hasClients) {
        offset = _scrollController.offset;
        viewportDimension = _scrollController.position.viewportDimension;
      }
      widget.onScrollStart?.call(offset, viewportDimension);
    }

    // 重置定时器
    _scrollTimer?.cancel();
    _scrollTimer = Timer(widget.scrollEndDelay, () {
      if (mounted) {
        _isScrolling = false;
        var offset = 0.0;
        var viewportDimension = 0.0;
        if (_scrollController.hasClients) {
          offset = _scrollController.offset;
          viewportDimension = _scrollController.position.viewportDimension;
        }
        widget.onScrollEnd?.call(offset, viewportDimension);
      }
    });

    // 滚动更新回调
    widget.onScrollUpdate?.call();
  }

  @override
  void dispose() {
    _scrollTimer?.cancel();
    // 内部创建的控制器才需要销毁
    if (widget.controller == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
