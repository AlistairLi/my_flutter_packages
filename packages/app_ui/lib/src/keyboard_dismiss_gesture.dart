import 'package:flutter/widgets.dart';

/// 在点击屏幕任意位置时，隐藏软键盘
/// 通常用于整个 App 的根布局中，确保用户点击空白处可以收起软键盘
class KeyboardDismissGesture extends StatelessWidget {
  final Widget child;

  const KeyboardDismissGesture({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode curFocus = FocusScope.of(context);
        if (!curFocus.hasPrimaryFocus && curFocus.focusedChild != null) {
          FocusManager.instance.primaryFocus?.unfocus();
        }
      },
      child: child,
    );
  }
}
