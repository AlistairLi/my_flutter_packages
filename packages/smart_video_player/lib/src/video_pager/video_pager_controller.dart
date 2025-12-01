import 'package:flutter/material.dart';

class VideoPagerController extends ChangeNotifier {
  VoidCallback? play;
  VoidCallback? pause;
  VoidCallback? nextPage;
  VoidCallback? previousPage;
  void Function(int index)? jumpToRealIndex;

  void playCurrent() => play?.call();

  void pauseAll() => pause?.call();

  void next() => nextPage?.call();

  void previous() => previousPage?.call();

  void jumpTo(int i) => jumpToRealIndex?.call(i);
}
