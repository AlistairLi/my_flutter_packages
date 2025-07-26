import 'package:flutter/material.dart';

/// 继承此组件获取软键盘高度
mixin AppKeyboardListener<T extends StatefulWidget>
    on State<T>, WidgetsBindingObserver {
  final WidgetsBinding _widgetsBinding = WidgetsBinding.instance;

  @override
  void initState() {
    _widgetsBinding.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    _widgetsBinding.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();

    // 获取键盘高度
    final viewInsets = EdgeInsets.fromWindowPadding(
        WidgetsBinding.instance.window.viewInsets,
        WidgetsBinding.instance.window.devicePixelRatio);

    onKeyboardHeightChanged(viewInsets.bottom);
  }

  void onKeyboardHeightChanged(double height) {}
}
