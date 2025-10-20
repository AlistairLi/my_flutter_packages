import 'package:app_theme/app_theme.dart';
import 'package:flutter/material.dart';

/// 定义可复用的渐变
class AppGradients {
  AppGradients._();

  // 动态渐变工厂
  static LinearGradient dynamic({
    required List<Color> colors,
    AlignmentGeometry? begin,
    AlignmentGeometry? end,
  }) {
    return LinearGradient(
      colors: colors,
      begin: begin ?? AlignmentDirectional.topStart,
      end: end ?? AlignmentDirectional.bottomEnd,
    );
  }

  // 主题相关渐变
  static LinearGradient fromTheme(ThemeData theme) {
    return LinearGradient(
      colors: [theme.primaryColor, theme.primaryColor.withValues(alpha: 0.8)],
      begin: AlignmentDirectional.topStart,
      end: AlignmentDirectional.bottomEnd,
    );
  }

  static const LinearGradient primary = LinearGradient(
    colors: [AppColors.mainGradientStart, AppColors.mainGradientEnd],
    begin: AlignmentDirectional.centerStart,
    end: AlignmentDirectional.centerEnd,
  );

  static const LinearGradient grey = LinearGradient(
    colors: [Colors.grey, Colors.grey],
    begin: AlignmentDirectional.centerStart,
    end: AlignmentDirectional.centerEnd,
  );
}
