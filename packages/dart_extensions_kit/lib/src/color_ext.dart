import 'package:flutter/material.dart';

/// Color 的扩展方法
extension ColorExtensions on Color {
  /// 获取十六进制字符串
  String get hex => '#${value.toRadixString(16).padLeft(8, '0').toUpperCase()}';

  /// 获取十六进制字符串（不包含透明度）
  String get hexRGB =>
      '#${(value & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';

  /// 获取RGB字符串
  String get rgb => 'rgb($r, $g, $b)';

  /// 获取RGBA字符串
  String get rgba => 'rgba($r, $g, $b, ${a.toStringAsFixed(2)})';

  /// 获取HSL值
  List<double> get hsl {
    final r = this.r / 255.0;
    final g = this.g / 255.0;
    final b = this.b / 255.0;

    final max = [r, g, b].reduce((a, b) => a > b ? a : b);
    final min = [r, g, b].reduce((a, b) => a < b ? a : b);
    final delta = max - min;

    double h = 0;
    double s = 0;
    final l = (max + min) / 2;

    if (delta != 0) {
      s = l > 0.5 ? delta / (2 - max - min) : delta / (max + min);

      if (max == r) {
        h = (g - b) / delta + (g < b ? 6 : 0);
      } else if (max == g) {
        h = (b - r) / delta + 2;
      } else {
        h = (r - g) / delta + 4;
      }
      h /= 6;
    }

    return [h * 360, s * 100, l * 100];
  }

  /// 获取HSL字符串
  String get hslString {
    final hslValues = hsl;
    return 'hsl(${hslValues[0].round()}, ${hslValues[1].round()}%, ${hslValues[2].round()}%)';
  }

  /// 检查是否为深色
  bool get isDark {
    final luminance = computeLuminance();
    return luminance < 0.5;
  }

  /// 检查是否为浅色
  bool get isLight => !isDark;

  /// 获取对比色（黑或白）
  Color get contrastColor => isDark ? Colors.white : Colors.black;

  /// 获取亮度
  double get luminance => computeLuminance();

  /// 调整亮度
  Color withBrightness(double brightness) {
    final hslValues = hsl;
    final newL = (hslValues[2] + brightness).clamp(0, 100).toDouble();
    return _hslToColor(hslValues[0], hslValues[1], newL);
  }

  /// 调整饱和度
  Color withSaturation(double saturation) {
    final hslValues = hsl;
    final newS = saturation.clamp(0, 100).toDouble();
    return _hslToColor(hslValues[0], newS, hslValues[2]);
  }

  /// 调整色相
  Color withHue(double hue) {
    final hslValues = hsl;
    final newH = hue.clamp(0, 360).toDouble();
    return _hslToColor(newH, hslValues[1], hslValues[2]);
  }

  /// 调整透明度
  Color withOpacity(double opacity) {
    return withAlpha((opacity * 255).round());
  }

  /// 混合颜色
  Color blend(Color other, double ratio) {
    final r = (this.r * (1 - ratio) + other.r * ratio).round();
    final g = (this.g * (1 - ratio) + other.g * ratio).round();
    final b = (this.b * (1 - ratio) + other.b * ratio).round();
    final a = (this.a * (1 - ratio) + other.a * ratio).round();
    return Color.fromARGB(a, r, g, b);
  }

  /// 获取互补色
  Color get complementary {
    final hslValues = hsl;
    final newH = (hslValues[0] + 180) % 360;
    return _hslToColor(newH, hslValues[1], hslValues[2]);
  }

  /// 获取相似色（色相偏移30度）
  Color get analogous {
    final hslValues = hsl;
    final newH = (hslValues[0] + 30) % 360;
    return _hslToColor(newH, hslValues[1], hslValues[2]);
  }

  /// 获取三色配色
  List<Color> get triadic {
    final hslValues = hsl;
    final h1 = (hslValues[0] + 120) % 360;
    final h2 = (hslValues[0] + 240) % 360;
    return [
      this,
      _hslToColor(h1, hslValues[1], hslValues[2]),
      _hslToColor(h2, hslValues[1], hslValues[2]),
    ];
  }

  /// 获取单色配色
  List<Color> get monochromatic {
    final hslValues = hsl;
    return [
      this,
      _hslToColor(hslValues[0], hslValues[1] * 0.8, hslValues[2] * 0.8),
      _hslToColor(hslValues[0], hslValues[1] * 0.6, hslValues[2] * 0.6),
      _hslToColor(hslValues[0], hslValues[1] * 0.4, hslValues[2] * 0.4),
    ];
  }

  /// 从十六进制字符串创建颜色
  static Color fromHex(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    return Color(int.parse(hex, radix: 16));
  }

  /// 从RGB值创建颜色
  static Color fromRGB(int r, int g, int b, [double a = 1.0]) {
    return Color.fromARGB((a * 255).round(), r, g, b);
  }

  /// 从HSL值创建颜色
  static Color fromHSL(double h, double s, double l, [double a = 1.0]) {
    return _hslToColor(h, s, l).withValues(alpha: a);
  }

  /// HSL转RGB的辅助方法
  static Color _hslToColor(double h, double s, double l) {
    h = h / 360;
    s = s / 100;
    l = l / 100;

    double r, g, b;

    if (s == 0) {
      r = g = b = l;
    } else {
      hue2rgb(p, q, t) {
        if (t < 0) t += 1;
        if (t > 1) t -= 1;
        if (t < 1 / 6) return p + (q - p) * 6 * t;
        if (t < 1 / 2) return q;
        if (t < 2 / 3) return p + (q - p) * (2 / 3 - t) * 6;
        return p;
      }

      final q = l < 0.5 ? l * (1 + s) : l + s - l * s;
      final p = 2 * l - q;
      r = hue2rgb(p, q, h + 1 / 3);
      g = hue2rgb(p, q, h);
      b = hue2rgb(p, q, h - 1 / 3);
    }

    return Color.fromARGB(
        255, (r * 255).round(), (g * 255).round(), (b * 255).round());
  }
}
