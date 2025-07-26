import 'dart:async';

import 'package:flutter/material.dart';

/// 缩放动画 Widget
///
/// 将子组件从最小倍数放大到最大倍数，再恢复到最终大小
/// 支持自动播放、手动触发、循环播放等模式
class ScaleAnimationWidget extends StatefulWidget {
  /// 子组件
  final Widget child;

  /// 动画持续时间
  final Duration duration;

  /// 最大缩放倍数，默认 1.2
  final double maxScale;

  /// 初始缩放倍数，默认 0.8
  final double minScale;

  /// 最终缩放倍数，默认 1.0（原始大小）
  final double finalScale;

  /// 动画曲线，默认 easeInOut
  final Curve curve;

  /// 是否自动播放，默认 false
  final bool autoPlay;

  /// 是否循环播放，默认 false
  final bool loop;

  /// 循环间隔时间，默认 2秒
  final Duration loopInterval;

  /// 动画完成回调
  final VoidCallback? onAnimationComplete;

  /// 是否启用点击触发，默认 false
  final bool enableTapTrigger;

  /// 点击回调
  final VoidCallback? onTap;

  const ScaleAnimationWidget({
    super.key,
    required this.child,
    required this.autoPlay,
    this.duration = const Duration(milliseconds: 600),
    this.maxScale = 1.2,
    this.minScale = 0.8,
    this.finalScale = 1.0,
    this.curve = Curves.easeInOut,
    this.loop = false,
    this.loopInterval = const Duration(seconds: 2),
    this.onAnimationComplete,
    this.enableTapTrigger = false,
    this.onTap,
  });

  @override
  State<ScaleAnimationWidget> createState() => _ScaleAnimationWidgetState();
}

class _ScaleAnimationWidgetState extends State<ScaleAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  Timer? _loopTimer;

  @override
  void initState() {
    super.initState();
    _setupAnimation();

    if (widget.autoPlay) {
      _startAnimation();
    }

    if (widget.loop) {
      _startLoop();
    }
  }

  @override
  void dispose() {
    _loopTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _setupAnimation() {
    // 动画总时长 = 放大时长 + 恢复时长
    final totalDuration = Duration(milliseconds: widget.duration.inMilliseconds * 2);
    
    _controller = AnimationController(
      duration: totalDuration,
      vsync: this,
    );

    // 创建完整的动画序列：minScale → maxScale → finalScale
    _scaleAnimation = TweenSequence<double>([
      // 第一阶段：从最小倍数放大到最大倍数
      TweenSequenceItem(
        tween: Tween<double>(
          begin: widget.minScale,
          end: widget.maxScale,
        ).chain(CurveTween(curve: widget.curve)),
        weight: 50.0, // 占动画总时长的50%
      ),
      // 第二阶段：从最大倍数恢复到最终大小
      TweenSequenceItem(
        tween: Tween<double>(
          begin: widget.maxScale,
          end: widget.finalScale,
        ).chain(CurveTween(curve: widget.curve)),
        weight: 50.0, // 占动画总时长的50%
      ),
    ]).animate(_controller);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onAnimationComplete?.call();

        // 如果是循环播放，则重新开始
        if (widget.loop) {
          _startLoop();
        }
      }
    });
  }

  void _startAnimation() {
    _controller.forward();
  }

  void _startLoop() {
    _loopTimer?.cancel();
    _loopTimer = Timer(widget.loopInterval, () {
      if (mounted && widget.loop) {
        _startAnimation();
      }
    });
  }

  void _handleTap() {
    if (widget.enableTapTrigger) {
      _startAnimation();
    }
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    Widget result = AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: widget.child,
        );
      },
    );

    if (widget.enableTapTrigger || widget.onTap != null) {
      result = GestureDetector(
        onTap: _handleTap,
        child: result,
      );
    }

    return result;
  }
}

/// 脉冲缩放动画 Widget
///
/// 简化版本，专门用于脉冲效果（从小变大再恢复到原始大小）
class PulseScaleWidget extends StatelessWidget {
  /// 子组件
  final Widget child;

  /// 动画持续时间
  final Duration duration;

  /// 最大缩放倍数，默认 1.2
  final double maxScale;

  /// 初始缩放倍数，默认 0.8
  final double minScale;

  /// 最终缩放倍数，默认 1.0（原始大小）
  final double finalScale;

  /// 是否自动播放，默认 true
  final bool autoPlay;

  /// 是否循环播放，默认 true
  final bool loop;

  /// 循环间隔时间，默认 1.5秒
  final Duration loopInterval;

  /// 动画完成回调
  final VoidCallback? onAnimationComplete;

  const PulseScaleWidget({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
    this.maxScale = 1.2,
    this.minScale = 0.8,
    this.finalScale = 1.0,
    this.autoPlay = true,
    this.loop = true,
    this.loopInterval = const Duration(milliseconds: 1500),
    this.onAnimationComplete,
  });

  @override
  Widget build(BuildContext context) {
    return ScaleAnimationWidget(
      child: child,
      duration: duration,
      maxScale: maxScale,
      minScale: minScale,
      finalScale: finalScale,
      curve: Curves.easeInOut,
      autoPlay: autoPlay,
      loop: loop,
      loopInterval: loopInterval,
      onAnimationComplete: onAnimationComplete,
    );
  }
}

/// 点击缩放动画 Widget
///
/// 简化版本，专门用于点击触发缩放效果（从小变大再恢复到原始大小）
class TapScaleWidget extends StatelessWidget {
  /// 子组件
  final Widget child;

  /// 动画持续时间
  final Duration duration;

  /// 最大缩放倍数，默认 1.2
  final double maxScale;

  /// 初始缩放倍数，默认 0.8
  final double minScale;

  /// 最终缩放倍数，默认 1.0（原始大小）
  final double finalScale;

  /// 点击回调
  final VoidCallback? onTap;

  const TapScaleWidget({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 400),
    this.maxScale = 1.2,
    this.minScale = 0.8,
    this.finalScale = 1.0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ScaleAnimationWidget(
      child: child,
      duration: duration,
      maxScale: maxScale,
      minScale: minScale,
      finalScale: finalScale,
      curve: Curves.easeInOut,
      autoPlay: false,
      loop: false,
      enableTapTrigger: true,
      onTap: onTap,
    );
  }
}
