import 'package:flutter/foundation.dart';
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

  /// 注销指定索引的控制器，只有当控制器匹配时才移除
  void unregisterController(
      int index, VideoPlayerController? expectedController) {
    // 严格检查：只有存储的控制器与期望的控制器是同一个实例时才移除
    if (_controllers[index] == expectedController) {
      _controllers.remove(index);
    }
  }

  VideoPlayerController? getController(int index) {
    return _controllers[index];
  }

  void setCurrentPlayingIndex(int index) {
    _currentPlayingIndex = index;
  }

  int? get currentPlayingIndex => _currentPlayingIndex;

  /// 播放指定索引的视频
  Future<void> playVideo(int index, {int retryCount = 0}) async {
    final controller = _controllers[index];

    // 如果 controller 为 null，尝试重试
    if (controller == null && retryCount > 0) {
      if (kDebugMode) {
        print(
            "[VideoControllerManager]: playVideo(), index: $index, controller is null, retryCount: $retryCount, Trying to retry...");
      }
      await Future.delayed(Duration(milliseconds: 50));
      return playVideo(index, retryCount: retryCount - 1);
    }

    // 先暂停当前播放的视频
    if (_currentPlayingIndex != null && _currentPlayingIndex != index) {
      final currentController = _controllers[_currentPlayingIndex];
      if (currentController != null &&
          currentController.value.isInitialized &&
          currentController.value.isPlaying) {
        currentController.pause();
      }
    }

    // 播放新视频
    if (controller != null) {
      // 如果已初始化则直接播放，否则等待初始化完成后再播放
      if (controller.value.isInitialized) {
        await controller.play();
      } else {
        // 创建具名监听器函数以便后续移除
        void onControllerUpdate() {
          if (controller.value.isInitialized) {
            controller.removeListener(onControllerUpdate); // 移除监听器
            if (!controller.value.isPlaying) {
              controller.play();
            }
          }
        }

        // 添加监听器
        controller.addListener(onControllerUpdate);

        // 双重检查：防止在添加监听器之前就已经初始化完成
        if (controller.value.isInitialized) {
          controller.removeListener(onControllerUpdate);
          if (!controller.value.isPlaying) {
            controller.play();
          }
        }
      }
    } else {
      if (kDebugMode) {
        print(
            "[VideoControllerManager]: playVideo(), index: $index, controller is null");
      }
    }

    _currentPlayingIndex = index;
  }

  /// 暂停所有视频
  void pauseAll() {
    for (var controller in _controllers.values) {
      if (controller.value.isInitialized && controller.value.isPlaying) {
        controller.pause();
      }
    }
  }
}
