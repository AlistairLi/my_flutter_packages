import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:visibility_detector/visibility_detector.dart';

const String _tag = "ScrollVisibilityListener";

/// 滚动和可见性监听器回调
typedef ScrollVisibilityCallback = void Function({
  bool isScrolling,
  bool isVisible,
  bool isInBackground,
});

/// 列表滚动和可见性监听器
///
/// 功能：
/// - 监听列表是否在滚动
/// - 监听界面是否可见
/// - 监听应用是否切换到后台
/// - 可控制是否监听滚动状态
/// 🔶[UNTESTED]
@Deprecated("see ScrollAndVisibilityListenerWidget")
class ScrollVisibilityListener extends StatefulWidget {
  final Widget child;
  final ScrollVisibilityCallback? onStateChanged;
  final bool enableScrollListener; // 控制是否监听滚动状态
  final Duration scrollDebounceTime; // 滚动停止判定时间
  final ScrollController? controller; // 允许外部传入控制器

  const ScrollVisibilityListener({
    super.key,
    required this.child,
    this.onStateChanged,
    this.enableScrollListener = true,
    this.scrollDebounceTime = const Duration(milliseconds: 150),
    this.controller,
  });

  @override
  State<ScrollVisibilityListener> createState() =>
      _ScrollVisibilityListenerState();
}

class _ScrollVisibilityListenerState extends State<ScrollVisibilityListener>
    with WidgetsBindingObserver {
  ScrollController? _scrollController;
  bool _isScrolling = false;
  bool _isVisible = true;
  bool _isInBackground = false; // isInForeground
  Timer? _scrollTimer;

  void _initScrollController() {
    if (widget.enableScrollListener) {
      // 使用外部传入的控制器或创建新的
      _scrollController = widget.controller ?? ScrollController();
      _scrollController?.addListener(_onScroll);
    }
  }

  void _onScroll() {
    if (!_isScrolling) {
      _isScrolling = true;
      _notifyStateChanged();
    }

    // 重置定时器
    _scrollTimer?.cancel();
    _scrollTimer = Timer(widget.scrollDebounceTime, () {
      if (mounted) {
        _isScrolling = false;
        _notifyStateChanged();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initScrollController();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollTimer?.cancel();
    if (widget.enableScrollListener && widget.controller == null) {
      // 只有内部创建的控制器才需要销毁
      _scrollController?.dispose();
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final wasInBackground = _isInBackground;
    // _isInBackground = state == AppLifecycleState.paused ||
    //     state == AppLifecycleState.inactive ||
    //     state == AppLifecycleState.detached;
    _isInBackground = state != AppLifecycleState.resumed;

    if (wasInBackground != _isInBackground) {
      _notifyStateChanged();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 检查当前路由是否可见
    final route = ModalRoute.of(context);
    if (route != null) {
      final isVisible = route.isCurrent;
      if (_isVisible != isVisible) {
        _isVisible = isVisible;
        if (kDebugMode) {
          print("$_tag, _isVisible: $_isVisible");
        }
        // 待定
        // _notifyStateChanged();
      }
    }
  }

  void _notifyStateChanged() {
    widget.onStateChanged?.call(
      isScrolling: _isScrolling,
      isVisible: _isVisible,
      isInBackground: _isInBackground,
    );
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key('${_tag}_visibility_detector_key'),
      onVisibilityChanged: (VisibilityInfo info) {
        final wasVisible = _isVisible;
        _isVisible = info.visibleFraction >= 1.0;
        if (wasVisible != _isVisible) {
          _notifyStateChanged();
        }
      },
      child: widget.child,
    );
  }
}
