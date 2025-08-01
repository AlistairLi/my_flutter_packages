import 'dart:math';

import 'package:flutter/material.dart';

/// Configuration class for watermark properties
///
/// This class defines all the customizable properties for the watermark,
/// including text styling, positioning, rotation, and opacity settings.
class Config {
  /// Text alignment for the watermark text
  final TextAlign textAlign;

  /// Text direction (left-to-right or right-to-left)
  final TextDirection textDirection;

  /// Locale for text rendering
  final Locale locale;

  /// Text style including color, font size, font weight, etc.
  final TextStyle textStyle;

  /// Background color of the watermark area
  final Color backgroundColor;

  /// Rotation angle of the watermark text in radians
  final double rotationAngle;

  /// Horizontal spacing between watermark instances
  final double horizontalInterval;

  /// Vertical spacing between watermark instances
  final double verticalInterval;

  /// Offset from the top-left corner of the widget
  final Offset offset;

  /// Creates a watermark configuration
  ///
  /// [textAlign] - Text alignment, defaults to center
  /// [textDirection] - Text direction, defaults to left-to-right
  /// [locale] - Locale for text rendering, defaults to English US
  /// [textStyle] - Text styling, defaults to white70 color with 12px font size
  /// [backgroundColor] - Background color, defaults to transparent
  /// [alpha] - Opacity level, defaults to 0.2 (20% opacity)
  /// [rotationAngle] - Rotation angle in radians, defaults to -45 degrees
  /// [horizontalInterval] - Horizontal spacing, defaults to 150 pixels
  /// [verticalInterval] - Vertical spacing, defaults to 150 pixels
  /// [offset] - Position offset, defaults to (0, 0)
  const Config({
    this.textAlign = TextAlign.center,
    this.textDirection = TextDirection.ltr,
    this.locale = const Locale('en', 'US'),
    this.textStyle = const TextStyle(
      color: Colors.white70,
      fontSize: 12,
    ),
    this.backgroundColor = const Color(0x00000000),
    this.rotationAngle = -pi / 4,
    this.horizontalInterval = 150,
    this.verticalInterval = 150,
    this.offset = const Offset(0, 0),
  });
}
