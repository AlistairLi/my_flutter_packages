class UIUtil {
  UIUtil._();

  /// 将 [0~100] 的百分比转换为 Alignment 的 x 值（范围 [-1.0, 1.0]）
  static double alignmentXFromPercent(double percent) {
    return (percent.clamp(0, 100) / 100) * 2 - 1;
  }
}
