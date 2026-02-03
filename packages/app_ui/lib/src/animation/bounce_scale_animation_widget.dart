import 'package:flutter/material.dart';

/// 弹跳式缩放动画：initialScale → 120% → 100% → (120% → 100%) × repeatCount
///
/// 与 [ScaleAnimationWidget] 区分：本组件为多关键帧序列（可重复 120%↔100%），
/// [ScaleAnimationWidget] 为单次 min→max→final 或循环间隔播放。
///
/// 每段过渡时长固定为 [segmentDuration]，且每段使用 [curve] 缓动。
///
/// 参数：
/// - [child] 需要做动画的 Widget
/// - [width] / [height] 容器宽高，可选
/// - [initialScale] 起始缩放比例
/// - [segmentDuration] 每一段过渡的时长
/// - [repeatCount] 首次 initialScale→120%→100% 之后，「120%→100%」重复的次数
/// - [curve] 每段过渡的缓动曲线
class BounceScaleAnimationWidget extends StatefulWidget {
  final Widget child;
  final double? width;
  final double? height;
  final double initialScale;
  final Duration segmentDuration;
  final int repeatCount;
  final Curve curve;

  const BounceScaleAnimationWidget({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.initialScale = 0.3,
    this.segmentDuration = const Duration(milliseconds: 400),
    this.repeatCount = 0,
    this.curve = Curves.easeInOut,
  });

  @override
  State<BounceScaleAnimationWidget> createState() =>
      _BounceScaleAnimationWidgetState();
}

class _BounceScaleAnimationWidgetState extends State<BounceScaleAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    final segmentCount = 2 + 2 * widget.repeatCount;
    _controller = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: widget.segmentDuration.inMilliseconds * segmentCount,
      ),
    );
    _scaleAnimation = _buildScaleAnimation();
    _controller.forward();
  }

  Animation<double> _buildScaleAnimation() {
    const double scale120 = 1.2;
    const double scale100 = 1.0;
    final double scaleStart = widget.initialScale;
    final List<TweenSequenceItem<double>> items = [];

    items.add(TweenSequenceItem<double>(
      tween: _CurvedScaleTween(
        begin: scaleStart,
        end: scale120,
        curve: widget.curve,
      ),
      weight: 1,
    ));
    items.add(TweenSequenceItem<double>(
      tween: _CurvedScaleTween(
        begin: scale120,
        end: scale100,
        curve: widget.curve,
      ),
      weight: 1,
    ));

    for (int i = 0; i < widget.repeatCount; i++) {
      items.add(TweenSequenceItem<double>(
        tween: _CurvedScaleTween(
          begin: scale100,
          end: scale120,
          curve: widget.curve,
        ),
        weight: 1,
      ));
      items.add(TweenSequenceItem<double>(
        tween: _CurvedScaleTween(
          begin: scale120,
          end: scale100,
          curve: widget.curve,
        ),
        weight: 1,
      ));
    }

    return TweenSequence<double>(items).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget content = ScaleTransition(
      scale: _scaleAnimation,
      child: widget.child,
    );
    if (widget.width != null || widget.height != null) {
      content = SizedBox(
        width: widget.width,
        height: widget.height,
        child: content,
      );
    }
    return content;
  }
}

class _CurvedScaleTween extends Animatable<double> {
  final double begin;
  final double end;
  final Curve curve;

  _CurvedScaleTween({
    required this.begin,
    required this.end,
    required this.curve,
  });

  @override
  double transform(double t) {
    final curved = curve.transform(t.clamp(0.0, 1.0));
    return begin + (end - begin) * curved;
  }
}
