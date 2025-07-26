import 'package:flutter/material.dart';

/// 带点击动画效果的按钮
class AnimatedClickableButton extends StatefulWidget {
  final ValueGetter onTap;
  final Widget child;

  AnimatedClickableButton({
    super.key,
    required this.onTap,
    required this.child,
  });

  @override
  State<AnimatedClickableButton> createState() =>
      _AnimatedClickableButtonState();
}

const _duration = Duration(milliseconds: 150);

class _AnimatedClickableButtonState extends State<AnimatedClickableButton>
    with SingleTickerProviderStateMixin {
  late double _scale;
  bool deferrable = false;
  DateTime? tapTime;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _setup();
  }

  _setup() {
    _controller = AnimationController(
      vsync: this,
      upperBound: 0.05,
      lowerBound: 0.0,
      duration: _duration,
    )..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    // ShakeUtil.shortShake();
    deferrable = false;
    tapTime = DateTime.now();
    _controller.reset();
    _controller.forward(from: 0);
  }

  void _onTapCancel() {
    reverse();
  }

  void _onTapUp(TapUpDetails details) {
    reverse();
  }

  void _onTap() {
    widget.onTap();
  }

  void reverse() {
    if (tapTime == null) _controller.reverse();
    Duration diffDuration = DateTime.now().difference(tapTime!);
    if (diffDuration < _duration) {
      deferrable = true;
      Future.delayed(_duration - diffDuration, () {
        if (deferrable) {
          _controller.reverse();
        }
      });
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    _scale = 1 - _controller.value;
    return GestureDetector(
      onTapUp: _onTapUp,
      onTapDown: _onTapDown,
      onTapCancel: _onTapCancel,
      onTap: _onTap,
      child: Transform.scale(
        scale: _scale,
        child: widget.child,
      ),
    );
  }
}
