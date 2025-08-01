import 'package:flutter/material.dart';
import 'package:flutter_watermark_plus/src/config/config.dart';
import 'package:flutter_watermark_plus/src/utils/watermark_painter_util.dart';

/// A widget that adds a text watermark overlay to its child widget
///
/// This widget wraps any child widget and adds a repeating text watermark
/// with customizable properties defined by the [Config] class.
class TextWatermarkWidget extends StatelessWidget {
  /// Unique key for the watermark custom paint widget
  static const Key watermarkKey = Key('watermark_custom_paint');

  /// The text to be displayed as watermark
  final String text;

  /// The child widget to be overlaid with watermark
  final Widget child;

  /// Configuration for watermark properties
  final Config config;

  /// Creates a text watermark widget
  ///
  /// [child] - The widget to be overlaid with watermark
  /// [text] - The text to display as watermark
  /// [config] - Configuration for watermark properties, uses default if not provided
  const TextWatermarkWidget({
    super.key,
    required this.text,
    required this.child,
    this.config = const Config(),
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Display the original child widget
        Positioned.fill(child: child),
        // Overlay the watermark on top
        Positioned.fill(
          child: ClipRect(
            child: CustomPaint(
              painter: _WatermarkPainter(
                text: text,
                config: config,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Custom painter that draws the watermark text
///
/// This painter creates a repeating pattern of the watermark text
/// across the entire canvas with the specified configuration.
class _WatermarkPainter extends CustomPainter {
  /// The text to be drawn as watermark
  final String text;

  /// Configuration for watermark properties
  final Config config;

  /// Creates a watermark painter
  ///
  /// [text] - The text to display as watermark
  /// [config] - Configuration for watermark properties
  _WatermarkPainter({
    required this.text,
    required this.config,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Use the common watermark drawing utility
    WatermarkPainterUtil.drawWatermarkPatternOnFlutterCanvas(
      canvas: canvas,
      size: size,
      text: text,
      config: config,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
