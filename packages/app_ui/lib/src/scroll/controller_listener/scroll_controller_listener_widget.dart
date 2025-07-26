import 'dart:async';

import 'package:flutter/material.dart';

/// ScrollController 滚动监听组件
class ScrollControllerListenerWidget extends StatefulWidget {
  final Widget child;
  final void Function(bool isScrolling)? onScrollStateChanged;
  final VoidCallback? onScrollStart;
  final VoidCallback? onScrollEnd;
  final VoidCallback? onScrollUpdate;
  final Duration scrollEndDelay;
  final ScrollController? controller; // 允许外部传入控制器

  const ScrollControllerListenerWidget({
    super.key,
    required this.child,
    this.onScrollStateChanged,
    this.onScrollStart,
    this.onScrollEnd,
    this.onScrollUpdate,
    this.scrollEndDelay = const Duration(milliseconds: 200),
    this.controller,
  });

  @override
  State<ScrollControllerListenerWidget> createState() =>
      _ScrollControllerListenerWidgetState();
}

class _ScrollControllerListenerWidgetState
    extends State<ScrollControllerListenerWidget> {
  late ScrollController _scrollController;
  bool _isScrolling = false;
  Timer? _scrollTimer;

  // 暴露控制器给外部使用
  ScrollController get controller => _scrollController;

  @override
  void initState() {
    super.initState();
    // 使用外部传入的控制器或创建新的
    _scrollController = widget.controller ?? ScrollController();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
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
        // });
        widget.onScrollStateChanged?.call(false);
        widget.onScrollEnd?.call();
      }
    });

    // 滚动更新回调
    widget.onScrollUpdate?.call();
  }

  @override
  void dispose() {
    _scrollTimer?.cancel();
    // 只有内部创建的控制器才需要销毁
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
