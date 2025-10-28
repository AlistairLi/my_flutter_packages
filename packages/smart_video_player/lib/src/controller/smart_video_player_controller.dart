import 'package:flutter/foundation.dart';

/// 视频播放控制器
class SmartVideoPlayerController extends ChangeNotifier {
  bool _isPlaying = false;
  bool _isInitialized = false;

  /// 是否正在播放
  bool get isPlaying => _isPlaying;

  /// 是否已初始化
  bool get isInitialized => _isInitialized;

  /// 播放
  void play() {
    if (_isInitialized && !_isPlaying) {
      _isPlaying = true;
      if (hasListeners) {
        notifyListeners();
      }
    }
  }

  /// 暂停
  void pause() {
    if (_isInitialized && _isPlaying) {
      _isPlaying = false;
      if (hasListeners) {
        notifyListeners();
      }
    }
  }

  /// 切换播放/暂停状态
  void togglePlayPause() {
    if (_isPlaying) {
      pause();
    } else {
      play();
    }
  }

  /// 设置初始化状态
  void setInitialized(bool initialized) {
    _isInitialized = initialized;
    if (hasListeners) {
      notifyListeners();
    }
  }

  /// 设置播放状态
  void setPlayingState(bool playing) {
    if (playing != _isPlaying) {
      _isPlaying = playing;
      if (hasListeners) {
        notifyListeners();
      }
    }
  }

  /// 格式化时间显示
  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    // return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
    return "$twoDigitMinutes:$twoDigitSeconds";
  }
}
