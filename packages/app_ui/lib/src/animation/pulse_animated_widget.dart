import 'package:flutter/material.dart';

/// 脉冲动画组件
///
/// 这个组件可以为任何子组件添加脉冲动画效果，常用于吸引用户注意的按钮
/// 动画效果：根据pulseCount执行指定次数的脉冲，然后等待intervalDuration后重新开始循环
/// 每次脉冲：正常大小 -> 放大 -> 正常大小
class PulseAnimatedWidget extends StatefulWidget {
  /// 需要添加动画效果的子组件
  final Widget child;

  /// 单次动画的持续时间（放大或缩小）
  final Duration animationDuration;

  /// 动画循环的间隔时间（每次动画序列完成后等待的时间）
  final Duration intervalDuration;

  /// 放大时的缩放比例（1.0为原始大小，1.1为放大10%）
  final double scaleFactor;

  /// 每次循环的脉冲次数（放大->缩小的完整过程算一次脉冲）
  /// 默认为2次，即：放大->缩小->放大->缩小
  final int pulseCount;

  const PulseAnimatedWidget({
    super.key,
    required this.child,
    this.animationDuration = const Duration(milliseconds: 200),
    this.intervalDuration = const Duration(seconds: 5),
    this.scaleFactor = 1.1,
    this.pulseCount = 2,
  });

  @override
  State<PulseAnimatedWidget> createState() => _PulseAnimatedWidgetState();
}

class _PulseAnimatedWidgetState extends State<PulseAnimatedWidget>
    with TickerProviderStateMixin {
  /// 动画控制器，用于控制动画的播放
  late AnimationController _controller;

  /// 缩放动画，控制组件的大小变化
  late Animation<double> _scaleAnimation;

  /// 当前脉冲次数计数器
  int _currentPulseCount = 0;

  @override
  void initState() {
    super.initState();

    // 初始化动画控制器
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    // 创建缩放动画，从1.0（正常大小）到scaleFactor（放大）
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleFactor,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut, // 使用缓入缓出曲线，动画更自然
    ));

    // 启动动画循环
    _startAnimation();
  }

  /// 启动动画循环
  /// 等待指定的间隔时间后开始执行动画序列
  void _startAnimation() {
    Future.delayed(widget.intervalDuration, () {
      if (mounted) {
        _performAnimationSequence();
      }
    });
  }

  /// 执行完整的动画序列
  /// 动画顺序：根据pulseCount执行指定次数的脉冲，然后重新开始循环
  void _performAnimationSequence() {
    if (!mounted) return;
    _currentPulseCount = 0;
    _performNextPulse();
  }

  /// 执行下一次脉冲动画
  void _performNextPulse() {
    if (!mounted) return;

    // 执行一次完整的脉冲：放大 -> 缩小
    _controller.forward().then((_) {
      if (!mounted) return;
      _controller.reverse().then((_) {
        if (!mounted) return;

        _currentPulseCount++;

        // 如果还没达到指定的脉冲次数，继续下一次脉冲
        if (_currentPulseCount < widget.pulseCount) {
          _performNextPulse();
        } else {
          // 脉冲序列完成，重新开始循环
          _startAnimation();
        }
      });
    });
  }

  @override
  void dispose() {
    // 释放动画控制器资源
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        // 使用Transform.scale应用缩放动画
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: widget.child,
        );
      },
    );
  }
}
