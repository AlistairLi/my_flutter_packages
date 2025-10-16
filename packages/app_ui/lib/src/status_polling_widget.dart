import 'dart:async';

import 'package:flutter/material.dart';
import 'package:scroll_detector/scroll_detector.dart';
import 'package:visibility_detector_widget/visibility_detector_widget.dart';

/// 状态轮询 Widget
/// 可用于以下场景的「在线状态」刷新
///   - 列表，包裹列表的组件
///   - 详情页
///   - 聊天页，包裹页面中的AppBar
///
/// 功能：
/// - 管理定时器生命周期
/// - 监听界面可见性，不可见时暂停刷新
/// - 监听滚动状态，滚动时暂停刷新
/// - 通过回调执行具体的刷新逻辑
class StatusPollingWidget extends StatefulWidget {
  /// 子组件
  final Widget child;

  /// 刷新间隔时长
  final Duration refreshInterval;

  /// 是否启用滚动时暂停刷新功能（滚动时暂停，滚动结束后恢复）
  final bool enableScrollPause;

  /// 是否启用不可见时暂停刷新功能（界面不可见时暂停，可见时恢复）
  final bool enableInvisibilityPause;

  /// 滚动结束时的延迟
  final Duration scrollEndDelay;

  /// 是否保持组件状态
  final bool keepAlive;

  /// 滚动控制器
  final ScrollController? scrollController;

  /// 刷新状态回调
  final Future<void> Function()? onRefreshStatus;

  /// 滚动结束时的偏移量回调
  final void Function(double offset)? onScrollEnd;

  /// 自定义日志标签
  final String? logTag;

  const StatusPollingWidget({
    super.key,
    required this.child,
    this.scrollController,
    this.onRefreshStatus,
    this.refreshInterval = const Duration(milliseconds: 5000),
    this.enableScrollPause = true,
    this.enableInvisibilityPause = true,
    this.scrollEndDelay = const Duration(milliseconds: 400),
    this.keepAlive = true,
    this.onScrollEnd,
    this.logTag,
  });

  @override
  State<StatusPollingWidget> createState() => _StatusPollingWidgetState();
}

class _StatusPollingWidgetState extends State<StatusPollingWidget>
    with AutomaticKeepAliveClientMixin {
  Timer? _timer;
  bool _isVisible = false;
  bool _isScrolling = false;

  @override
  bool get wantKeepAlive => widget.keepAlive;

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }

  /// 开始定时器
  void _startTimer() {
    _timer = Timer.periodic(widget.refreshInterval, (timer) {
      _executeRefresh();
    });
  }

  /// 停止定时器
  void _stopTimer() {
    if (_timer != null) {
      _timer?.cancel();
      _timer = null;
    }
  }

  /// 执行刷新
  Future<void> _executeRefresh() async {
    widget.onRefreshStatus?.call();
  }

  /// 更新刷新状态
  void _updateRefreshState() {
    if ((_isVisible) && (!_isScrolling)) {
      _executeRefresh();
      _stopTimer();
      _startTimer();
    } else {
      _stopTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    Widget current = widget.child;

    if (widget.enableInvisibilityPause) {
      current = VisibilityDetectorWidget(
        child: current,
        onVisible: () {
          _isVisible = true;
          _updateRefreshState();
        },
        onInvisible: () {
          _isVisible = false;
          _updateRefreshState();
        },
      );
    }

    if (widget.enableScrollPause) {
      current = ScrollDetector(
        child: current,
        controller: widget.scrollController,
        scrollEndDelay: widget.scrollEndDelay,
        onScrollStart: (offset) {
          _isScrolling = true;
          _updateRefreshState();
        },
        onScrollEnd: (offset) {
          _isScrolling = false;
          widget.onScrollEnd?.call(offset);
          _updateRefreshState();
        },
      );
    }
    return current;
  }
}
