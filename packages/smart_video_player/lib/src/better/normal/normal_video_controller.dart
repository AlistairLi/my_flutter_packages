import 'package:better_player_plus/better_player_plus.dart';

class NormalVideoController {
  BetterPlayerController? _internalController;

  /// 播放
  Future<void> play() async {
    await _internalController?.play();
  }

  /// 暂停
  Future<void> pause() async {
    await _internalController?.pause();
  }

  /// 跳转
  Future<void> seekTo(Duration position) async {
    await _internalController?.seekTo(position);
  }

  /// 静音设置
  Future<void> setVolume(double volume) async {
    await _internalController?.setVolume(volume);
  }

  /// 是否正在播放
  bool get isPlaying =>
      _internalController?.videoPlayerController?.value.isPlaying ?? false;

  /// 内部使用
  void attachPlayer(BetterPlayerController controller) {
    _internalController = controller;
  }

  /// 销毁
  void dispose() {
    // 不销毁 BetterPlayerController，由 Page 管理
    _internalController = null;
  }
}
