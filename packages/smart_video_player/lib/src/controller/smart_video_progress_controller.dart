import 'package:flutter/foundation.dart';

/// 视频进度控制器
class SmartVideoProgressController extends ChangeNotifier {
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isDragging = false;

  /// 当前播放位置
  Duration get position => _position;

  /// 视频总时长
  Duration get duration => _duration;

  /// 是否正在拖拽进度条
  bool get isDragging => _isDragging;

  /// 播放进度百分比 (0.0 - 1.0)
  double get progress {
    if (_duration.inMilliseconds == 0) return 0.0;
    return _position.inMilliseconds / _duration.inMilliseconds;
  }

  /// 更新播放位置
  void updatePosition(Duration position) {
    if (_isDragging != true && _position != position) {
      _position = position;
      if (hasListeners) {
        notifyListeners();
      }
    }
  }

  /// 更新视频时长
  void updateDuration(Duration duration) {
    if (_duration != duration) {
      _duration = duration;
      if (hasListeners) {
        notifyListeners();
      }
    }
  }

  /// 设置拖拽状态
  void setDragging(bool dragging) {
    if (_isDragging != dragging) {
      _isDragging = dragging;
      if (hasListeners) {
        notifyListeners();
      }
    }
  }

  /// 跳转到指定位置
  void seekTo(Duration position) {
    _position = position;
    if (hasListeners) {
      notifyListeners();
    }
  }

  /// 格式化时间显示
  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }
}
