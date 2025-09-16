import 'package:flutter/material.dart';

/// SizedBox
class AppSizedBox extends StatelessWidget {
  final double? width;
  final double? height;
  final Widget? child;

  /// 仅设置宽度
  const AppSizedBox.w(this.width, {super.key, this.child}) : height = null;

  /// 仅设置高度
  const AppSizedBox.h(this.height, {super.key, this.child}) : width = null;

  /// 设置宽度和高度
  const AppSizedBox.wh(this.width, this.height, {super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: child,
    );
  }
}

/// 设置宽度
SizedBox sizedBoxWidth(double width, {Widget? child}) {
  return SizedBox(
    width: width,
    child: child,
  );
}

/// 设置高度
SizedBox sizedBoxHeight(double height, {Widget? child}) {
  return SizedBox(
    height: height,
    child: child,
  );
}
