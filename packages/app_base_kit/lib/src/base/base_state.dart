import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// 一个可以自动打点的 State 基类
abstract class BaseState<T extends StatefulWidget> extends State<T> {
  /// 页面名称，子类可以覆盖以提供自定义页面名称
  String get pageName => runtimeType.toString();

  @override
  void initState() {
    super.initState();
    _onPageOpen();
  }

  @override
  void dispose() {
    _onPageClose();
    super.dispose();
  }

  /// 页面打开打点
  void _onPageOpen() {
    if (kDebugMode) {
      print("Page Opened: $pageName");
    }
    // 打点逻辑...
  }

  /// 页面关闭打点
  void _onPageClose() {
    if (kDebugMode) {
      print("Page Closed: $pageName");
    }
    // 打点逻辑...
  }
}
