import 'package:flutter/material.dart';

/// 旋转 + 透明度循环动画
///
/// 持续旋转，同时透明度在 [opacityMin]～[opacityMax] 之间往复。
///
/// 参数：
/// - [child] 需要做动画的 Widget
/// - [width] / [height] 容器宽高，可选
/// - [rotationDuration] 旋转一圈的时长
/// - [opacityMin] / [opacityMax] 透明度变化范围，默认 0.7～1.0
/// - [opacityDuration] 透明度每次变化的时长
class RotateFadeAnimationWidget extends StatefulWidget {
  final Widget child;
  final double? width;
  final double? height;
  final Duration rotationDuration;
  final double opacityMin;
  final double opacityMax;
  final Duration opacityDuration;

  const RotateFadeAnimationWidget({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.rotationDuration = const Duration(seconds: 3),
    this.opacityMin = 0.7,
    this.opacityMax = 1.0,
    this.opacityDuration = const Duration(milliseconds: 800),
  });

  @override
  State<RotateFadeAnimationWidget> createState() =>
      _RotateFadeAnimationWidgetState();
}

class _RotateFadeAnimationWidgetState extends State<RotateFadeAnimationWidget>
    with TickerProviderStateMixin {
  late final AnimationController _rotationController;
  late final AnimationController _opacityController;
  late final Animation<double> _rotationAnimation;
  late final Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      vsync: this,
      duration: widget.rotationDuration,
    )..repeat();
    _rotationAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear),
    );

    _opacityController = AnimationController(
      vsync: this,
      duration: widget.opacityDuration,
    )..repeat(reverse: true);
    _opacityAnimation = Tween<double>(
      begin: widget.opacityMin,
      end: widget.opacityMax,
    ).animate(
      CurvedAnimation(parent: _opacityController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _opacityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget content = FadeTransition(
      opacity: _opacityAnimation,
      child: RotationTransition(
        turns: _rotationAnimation,
        child: widget.child,
      ),
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
