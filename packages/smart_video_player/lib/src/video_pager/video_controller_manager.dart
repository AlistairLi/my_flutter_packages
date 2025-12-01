import 'package:video_player/video_player.dart';

class VideoControllerManager {
  static final VideoControllerManager _instance =
      VideoControllerManager._internal();

  factory VideoControllerManager() => _instance;

  VideoControllerManager._internal();

  final Map<int, VideoPlayerController> _controllers = {};
  int? _currentPlayingIndex;

  void registerController(int index, VideoPlayerController controller) {
    _controllers[index] = controller;
  }

  void unregisterController(int index) {
    _controllers.remove(index);
  }

  VideoPlayerController? getController(int index) {
    return _controllers[index];
  }

  void setCurrentPlayingIndex(int index) {
    _currentPlayingIndex = index;
  }

  int? get currentPlayingIndex => _currentPlayingIndex;

  /// 播放指定索引的视频
  Future<void> playVideo(int index) async {
    // 先暂停当前播放的视频
    if (_currentPlayingIndex != null && _currentPlayingIndex != index) {
      final currentController = _controllers[_currentPlayingIndex];
      if (currentController != null && currentController.value.isInitialized) {
        currentController.pause();
      }
    }

    // 播放新视频
    final controller = _controllers[index];
    if (controller != null) {
      // 如果已初始化则直接播放，否则等待初始化完成后再播放
      if (controller.value.isInitialized) {
        await controller.play();
      } else {
        controller.addListener(() {
          if (controller.value.isInitialized &&
              controller.value.isPlaying == false) {
            controller.play();
          }
        });
      }
    }

    _currentPlayingIndex = index;
  }

  /// 暂停所有视频
  void pauseAll() {
    for (var controller in _controllers.values) {
      if (controller.value.isInitialized) {
        controller.pause();
      }
    }
  }
}
