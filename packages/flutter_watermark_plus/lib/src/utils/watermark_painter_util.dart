import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_watermark_plus/src/config/config.dart';

/// Utility class for drawing watermark text on canvas
///
/// This class provides a common implementation for drawing watermark text
/// that can be used by both widget-based and image-based watermark engines.
class WatermarkPainterUtil {
  /// Draws watermark text pattern on the given canvas
  ///
  /// [canvas] - The canvas to draw on
  /// [size] - The size of the drawing area
  /// [text] - The text to display as watermark
  /// [config] - Configuration for watermark properties
  @Deprecated("")
  static void drawWatermarkPattern({
    required ui.Canvas canvas,
    required ui.Size size,
    required String text,
    required Config config,
  }) {
    // Draw the background color
    canvas.drawRect(
      ui.Rect.fromLTWH(0, 0, size.width, size.height),
      ui.Paint()..color = config.backgroundColor,
    );

    // Create text span with the specified style
    final textSpan = TextSpan(
      text: text,
      style: config.textStyle,
    );

    // Create text painter with configuration
    final textPainter = TextPainter(
      text: textSpan,
      textAlign: config.textAlign,
      textDirection: config.textDirection,
      locale: config.locale,
    );
    textPainter.layout();

    // Draw watermark text in a repeating pattern
    for (double y = 0 + config.offset.dy;
        y < size.height * 2;
        y += config.verticalInterval) {
      for (double x = 0 + config.offset.dx;
          x < size.width * 2;
          x += config.horizontalInterval) {
        // Save canvas state before transformation
        canvas.save();
        // Translate to position
        canvas.translate(x, y);
        // Apply rotation
        canvas.rotate(config.rotationAngle);
        // Paint the text
        textPainter.paint(
          canvas,
          ui.Offset.zero,
        );
        // Restore canvas state
        canvas.restore();
      }
    }
  }

  /// Draws watermark text pattern on Flutter Canvas
  ///
  /// [canvas] - The Flutter canvas to draw on
  /// [size] - The size of the drawing area
  /// [text] - The text to display as watermark
  /// [config] - Configuration for watermark properties
  static void drawWatermarkPatternOnFlutterCanvas({
    required Canvas canvas,
    required Size size,
    required String text,
    required Config config,
  }) {
    // Draw the background color
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = config.backgroundColor,
    );

    // Create text span with the specified style
    final textSpan = TextSpan(
      text: text,
      style: config.textStyle,
    );

    // Create text painter with configuration
    final textPainter = TextPainter(
      text: textSpan,
      textAlign: config.textAlign,
      textDirection: config.textDirection,
      locale: config.locale,
    );
    textPainter.layout();

    // Draw watermark text in a repeating pattern
    for (double y = 0 + config.offset.dy;
        y < size.height * 2;
        y += config.verticalInterval) {
      for (double x = 0 + config.offset.dx;
          x < size.width * 2;
          x += config.horizontalInterval) {
        // Save canvas state before transformation
        canvas.save();
        // Translate to position
        canvas.translate(x, y);
        // Apply rotation
        canvas.rotate(config.rotationAngle);
        // Paint the text
        textPainter.paint(
          canvas,
          Offset.zero,
        );
        // Restore canvas state
        canvas.restore();
      }
    }
  }
}
