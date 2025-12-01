import 'package:flutter/material.dart';
import 'package:smart_video_player/smart_video_player.dart';

typedef VideoOverlayBuilder = Widget Function(
  BuildContext context,
  VideoItem item, {
  int? index,
});
