import 'dart:async';

import 'package:app_ui/shared_widgets.dart';
import 'package:app_ui/src/ui_logger.dart';
import 'package:flutter/material.dart';

/// 定时刷新状态 Widget
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
  /// 可见性监听key
  final String visibilityKey;

  /// 子组件
  final Widget child;

  /// 滚动控制器（可选）
  final ScrollController? scrollController;

  /// 配置
  final StatusPollingConfig config;

  /// 刷新状态回调 - 由调用方实现具体逻辑
  final Future<void> Function()? onRefreshStatus;

  const StatusPollingWidget({
    super.key,
    required this.visibilityKey,
    required this.child,
    this.scrollController,
    this.config = const StatusPollingConfig(),
    this.onRefreshStatus,
  });

  @override
  State<StatusPollingWidget> createState() => _StatusPollingWidgetState();
}

class _StatusPollingWidgetState extends State<StatusPollingWidget>
    with AutomaticKeepAliveClientMixin {
  Timer? _timer;
  bool _isScrolling = false;
  bool _isVisible = true;
  bool _isInForeground = true;

  String get _logTag => widget.config.logTag ?? "OnlineStatusRefresh";

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }

  /// 开始定时器
  void _startTimer() {
    _stopTimer();
    if (widget.onRefreshStatus != null) {
      _timer = Timer.periodic(widget.config.refreshInterval, (timer) {
        _executeRefresh();
      });
      uiLog("开始定时刷新在线状态", tag: _logTag);
    }
  }

  /// 停止定时器
  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
    uiLog("停止定时刷新在线状态", tag: _logTag);
  }

  /// 执行刷新
  Future<void> _executeRefresh() async {
    if (widget.onRefreshStatus != null) {
      try {
        await widget.onRefreshStatus!();
        uiLog("执行在线状态刷新", tag: _logTag);
      } catch (e) {
        uiLog("刷新在线状态失败: $e", tag: _logTag);
      }
    }
  }

  /// 检查是否应该刷新
  bool _shouldRefresh() {
    if (widget.config.enableScrollPause && _isScrolling) return false;
    if (widget.config.enableInvisibilityPause && !_isVisible) return false;
    if (widget.config.enableBackgroundPause && !_isInForeground) return false;
    return true;
  }

  /// 更新刷新状态
  void _updateRefreshState() {
    if (_shouldRefresh()) {
      _executeRefresh(); // 先执行一次
      if (_timer == null && widget.onRefreshStatus != null) {
        _startTimer();
      }
    } else {
      if (_timer != null) {
        _stopTimer();
      }
    }
  }

  /// 滚动状态变化回调
  void _onScrollStateChanged(bool isScrolling) {
    _isScrolling = isScrolling;
    _updateRefreshState();
  }

  /// 可见性变化回调
  void _onVisibilityChanged(bool isVisible, bool isInForeground) {
    _isVisible = isVisible;
    _isInForeground = isInForeground;
    _updateRefreshState();
  }

  @override
  bool get wantKeepAlive => widget.config.keepAlive;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    Widget current = VisibilityListenerWidget(
      onStateChanged: (widget.config.enableInvisibilityPause ||
              widget.config.enableBackgroundPause)
          ? _onVisibilityChanged
          : null,
      visibilityKey: widget.visibilityKey,
      child: widget.child,
    );

    if (widget.config.enableScrollPause) {
      current = ScrollControllerListenerWidget(
        controller: widget.scrollController,
        onScrollStateChanged: _onScrollStateChanged,
        child: current,
      );
    }
    return current;
  }
}

/// 在线状态刷新配置
class StatusPollingConfig {
  /// 刷新间隔
  final Duration refreshInterval;

  /// 是否启用滚动时暂停刷新功能（滚动时暂停，滚动结束后恢复）
  final bool enableScrollPause;

  /// 是否启用不可见时暂停刷新功能（界面不可见时暂停，可见时恢复）
  final bool enableInvisibilityPause;

  /// 是否启用后台时暂停刷新功能（应用切换到后台时暂停，回到前台时恢复）
  final bool enableBackgroundPause;

  /// 是否保持组件状态
  final bool keepAlive;

  /// 自定义日志标签
  final String? logTag;

  const StatusPollingConfig({
    this.refreshInterval = const Duration(milliseconds: 7500),
    this.enableScrollPause = true,
    this.enableInvisibilityPause = true,
    this.enableBackgroundPause = true,
    this.keepAlive = true,
    this.logTag,
  });
}
