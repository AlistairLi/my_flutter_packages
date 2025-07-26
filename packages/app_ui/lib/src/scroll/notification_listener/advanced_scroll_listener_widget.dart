import 'dart:async';

import 'package:flutter/material.dart';

/// 滚动监听组件（带延迟检测）
///
/// 在滚动监听中，存在一个常见问题：
///   - ScrollEndNotification 在用户停止滚动时立即触发
///   - 但实际上用户可能只是短暂停顿，还会继续滚动
///   - 这会导致状态频繁切换，用户体验不好
///
/// 工作原理：
///   - 用户开始滚动 → 立即触发 onScrollStart
///   - 用户停止滚动 → 启动延迟定时器
///   - 如果在延迟时间内继续滚动 → 取消定时器，重新开始
///   - 如果延迟时间内没有继续滚动 → 执行 onScrollEnd
///
/// 使用场景
///   - 隐藏/显示工具栏
///   - 图片浏览器的缩放控制
///   - 阅读器的进度指示器
///   🔶[UNTESTED]
class AdvancedScrollListenerWidget extends StatefulWidget {
  final Widget child;
  final Function(bool isScrolling)? onScrollStateChanged;
  final VoidCallback? onScrollStart;
  final VoidCallback? onScrollEnd;
  final VoidCallback? onScrollUpdate;
  final Duration scrollEndDelay;

  /// 是否拦截事件
  final bool shouldInterceptEvents;

  const AdvancedScrollListenerWidget({
    super.key,
    required this.child,
    this.onScrollStateChanged,
    this.onScrollStart,
    this.onScrollEnd,
    this.onScrollUpdate,
    this.scrollEndDelay = const Duration(milliseconds: 150),
    this.shouldInterceptEvents = false,
  });

  @override
  State<AdvancedScrollListenerWidget> createState() =>
      _AdvancedScrollListenerWidgetState();
}

class _AdvancedScrollListenerWidgetState
    extends State<AdvancedScrollListenerWidget> {
  // bool _isScrolling = false;
  Timer? _scrollTimer;

  bool _onScrollNotification(ScrollNotification notification) {
    if (notification is ScrollStartNotification) {
      _handleScrollStart();
    } else if (notification is ScrollEndNotification) {
      _handleScrollEnd();
    } else if (notification is ScrollUpdateNotification) {
      _handleScrollUpdate();
    }
    return widget.shouldInterceptEvents;
  }

  void _handleScrollStart() {
    // if (!_isScrolling) {
    //   setState(() {
    //     _isScrolling = true;
    //   });
    widget.onScrollStateChanged?.call(true);
    widget.onScrollStart?.call();
    // }
  }

  void _handleScrollEnd() {
    _scrollTimer?.cancel();
    _scrollTimer = Timer(widget.scrollEndDelay, () {
      if (mounted) {
        // setState(() {
        //   _isScrolling = false;
        // });
        widget.onScrollStateChanged?.call(false);
        widget.onScrollEnd?.call();
      }
    });
  }

  void _handleScrollUpdate() {
    widget.onScrollUpdate?.call();
  }

  @override
  void dispose() {
    _scrollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: _onScrollNotification,
      child: widget.child,
    );
  }
}
