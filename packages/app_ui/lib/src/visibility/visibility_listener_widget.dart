import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:visibility_detector/visibility_detector.dart';

const String _tag = "VisibilityListenerWidget";

/// 可见性监听Widget
///
/// 功能：
/// - 监听界面是否可见
/// - 监听是否切换到后台
class VisibilityListenerWidget extends StatefulWidget {
  final Widget child;

  /// 监听可见性状态的key
  /// 在 TabBar+TabBarView中使用必须传visibilityKey,且值必须唯一
  final String? visibilityKey;
  final void Function(bool isVisible, bool isInForeground)? onStateChanged;

  const VisibilityListenerWidget({
    super.key,
    required this.child,
    this.visibilityKey,
    this.onStateChanged,
  });

  @override
  State<VisibilityListenerWidget> createState() =>
      _VisibilityListenerWidgetState();
}

class _VisibilityListenerWidgetState extends State<VisibilityListenerWidget>
    with WidgetsBindingObserver {
  bool _isVisible = true;
  bool _isInForeground = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final wasInForeground = _isInForeground;
    _isInForeground = state == AppLifecycleState.resumed;

    if (wasInForeground != _isInForeground) {
      _notifyStateChanged();
    }
  }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   // 检查当前路由是否可见
  //   final route = ModalRoute.of(context);
  //   if (route != null) {
  //     final isVisible = route.isCurrent;
  //     if (_isVisible != isVisible) {
  //       _isVisible = isVisible;
  //       if (kDebugMode) {
  //         print("$_tag, _isVisible: $_isVisible");
  //       }
  //       // 待定
  //       // _notifyStateChanged();
  //     }
  //   }
  // }

  void _notifyStateChanged() {
    widget.onStateChanged?.call(_isVisible, _isInForeground);
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key(widget.visibilityKey ?? '${_tag}_visibility_detector_key'),
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
