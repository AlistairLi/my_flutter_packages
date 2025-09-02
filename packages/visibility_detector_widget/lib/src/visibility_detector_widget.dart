import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:visibility_detector/visibility_detector.dart';

/// 可见性监听Widget
///
/// 功能：
/// - 监听界面是否可见
/// - 监听是否切换到后台
class VisibilityDetectorWidget extends StatefulWidget {
  final Widget child;
  final void Function(bool isVisible, bool isInForeground)? onStateChanged;
  final VoidCallback? onVisible;
  final VoidCallback? onInvisible;

  const VisibilityDetectorWidget({
    super.key,
    required this.child,
    this.onStateChanged,
    this.onVisible,
    this.onInvisible,
  });

  @override
  State<VisibilityDetectorWidget> createState() =>
      _VisibilityDetectorWidgetState();
}

class _VisibilityDetectorWidgetState extends State<VisibilityDetectorWidget>
    with WidgetsBindingObserver {
  final _key = UniqueKey();
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

  void _handleVisibilityInfoChanged(VisibilityInfo info) {
    final wasVisible = _isVisible;
    if (info.visibleFraction == 1.0) {
      _isVisible = true;
      if (wasVisible != _isVisible) {
        _notifyStateChanged();
      }
    } else if (info.visibleFraction == 0.0) {
      _isVisible = false;
      if (wasVisible != _isVisible) {
        _notifyStateChanged();
      }
    }
  }

  void _notifyStateChanged() {
    widget.onStateChanged?.call(_isVisible, _isInForeground);
    var visible = _isVisible && _isInForeground;
    if (visible) {
      widget.onVisible?.call();
    } else {
      widget.onInvisible?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: _key,
      onVisibilityChanged: _handleVisibilityInfoChanged,
      child: widget.child,
    );
  }
}
