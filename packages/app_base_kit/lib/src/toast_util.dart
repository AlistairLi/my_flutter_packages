import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

/// Toast 工具
// class ToastUtil {
//   ToastUtil._();
//
//   static showToast(
//     String msg, {
//     Toast toastLength = Toast.LENGTH_SHORT,
//     ToastGravity position = ToastGravity.CENTER,
//     int time = 2,
//     double fontSize = 16.0,
//     Color backColor = Colors.black,
//     Color textColor = Colors.white,
//   }) {
//     Fluttertoast.showToast(
//       msg: msg,
//       toastLength: toastLength,
//       gravity: position,
//       timeInSecForIosWeb: time,
//       backgroundColor: backColor,
//       textColor: textColor,
//       fontSize: 16.0,
//     );
//   }
// }

void mToast(
  String msg, {
  Toast toastLength = Toast.LENGTH_SHORT,
  ToastGravity position = ToastGravity.CENTER,
  int time = 2,
  double fontSize = 16.0,
  Color backColor = Colors.black,
  Color textColor = Colors.white,
}) {
  Fluttertoast.showToast(
    msg: msg,
    toastLength: toastLength,
    gravity: position,
    timeInSecForIosWeb: time,
    backgroundColor: backColor,
    textColor: textColor,
    fontSize: 16.0,
  );
}
