import 'package:flutter/material.dart';

/// [FlagEmojiCirclePainter] 是一个自定义画笔类，用于在圆形区域内绘制国旗表情符号。
/// 它通过动态计算字体大小，确保国旗表情符号能够完美填满圆形区域。
/// 主要参数：
/// - [flagEmoji]：国旗表情符号字符串。
/// - [factor]：放大系数，用于调整国旗表情符号的显示大小，默认值为 3.0。
///
/// 使用
/// CustomPaint(
///   size: Size(14.w, 14.w),
///   painter: FlagEmojiCirclePainter(
///   flagEmoji: country?.flagEmoji ?? "",
///  ),
/// )
class FlagEmojiCirclePainter extends CustomPainter {
  final String flagEmoji;
  final double factor; // 放大系数，可根据需要调整

  FlagEmojiCirclePainter({
    required this.flagEmoji,
    this.factor = 3.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    // 1. 先绘制一个圆形裁剪区域
    canvas.save();
    canvas.clipPath(
      Path()..addOval(Rect.fromCircle(center: center, radius: radius)),
    );

    // 2. 动态计算emoji字体大小，确保填满圆形
    final textStyle = TextStyle(
      fontSize: radius * factor, // 放大系数，可根据需要调整
      letterSpacing: 0,
      height: 1,
    );

    final textPainter = TextPainter(
      text: TextSpan(
        text: flagEmoji,
        style: textStyle,
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout();

    // 3. 精确居中绘制（考虑emoji的视觉平衡）
    final offset = Offset(
      center.dx - textPainter.width / 2,
      center.dy - textPainter.height / 2, // 微调垂直位置
    );
    textPainter.paint(canvas, offset);

    canvas.restore();

    // 4. 可选：绘制圆形边框
    canvas.drawCircle(center, radius, Paint()..color = Colors.transparent
        // ..style = PaintingStyle.stroke
        // ..strokeWidth = 1,
        );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is! FlagEmojiCirclePainter) return true;
    return oldDelegate.flagEmoji != flagEmoji;
  }
}
