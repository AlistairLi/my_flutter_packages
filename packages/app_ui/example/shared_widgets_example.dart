import 'package:app_ui/shared_widgets.dart';
import 'package:flutter/material.dart';

void main() {
  var awesome = Awesome();
  print('awesome: ${awesome.isAwesome}');
}

void showDialogTest(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AppCupertinoCustomConfirmDialog(
      content: 'Are you sure to switch the language?',
      leftText: 'Cancel',
      rightText: 'Confirm',
      onLeftTap: () {},
      onRightTap: () {},
      // 下面这些参数都可以自定义
      backgroundColor: Color(0xFF6C5A89),
      borderRadius: 16,
      leftTextStyle: TextStyle(color: Colors.white70, fontSize: 16),
      rightTextStyle: TextStyle(
        color: Color(0xFFFF5DF6),
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    ),
  );
}
