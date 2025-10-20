import 'package:app_theme/app_theme.dart';
import 'package:flutter/material.dart';

class AppTextStyles {
  AppTextStyles._();

  static final String saira = 'Saira';

  /// 大型标题或展示性文本（Display）
  static TextStyle displayLarge = TextStyle(
    fontSize: 57.sp,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    letterSpacing: -0.25,
  );

  static TextStyle displayMedium = TextStyle(
    fontSize: 45.sp,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    color: AppColors.textSecondary,
  );

  static TextStyle displaySmall = TextStyle(
    fontSize: 36.sp,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    color: AppColors.textSecondary,
  );

  /// 页面主标题或重要分区标题（Headline）
  static TextStyle headlineLarge = TextStyle(
    fontSize: 32.sp,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    color: AppColors.textSecondary,
  );

  static TextStyle headlineMedium = TextStyle(
    fontSize: 28.sp,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    color: AppColors.textSecondary,
  );

  static TextStyle headlineSmall = TextStyle(
    fontSize: 24.sp,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    color: AppColors.textSecondary,
  );

  /// 列表标题、卡片标题、AppBar标题等
  static TextStyle titleLarge = TextStyle(
    fontSize: 22.sp,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static TextStyle titleMedium = TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
    color: AppColors.textSecondary,
  );

  static TextStyle titleSmall = TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    color: AppColors.textTertiary,
  );

  /// 正文文本、描述信息等主要内容
  static TextStyle bodyLarge = TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    color: AppColors.textPrimary,
  );

  static TextStyle bodyMedium = TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    color: AppColors.textSecondary,
  );

  static TextStyle bodySmall = TextStyle(
    fontSize: 12.sp,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    color: AppColors.textTertiary,
  );

  /// 按钮文字、标签、辅助控件说明等小块文字
  static TextStyle labelLarge = TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    color: AppColors.textSecondary,
  );

  static TextStyle labelMedium = TextStyle(
    fontSize: 12.sp,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    color: AppColors.textSecondary,
  );

  static TextStyle labelSmall = TextStyle(
    fontSize: 11.sp,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    color: AppColors.textTertiary,
  );

  // 特殊样式
  static TextStyle caption = TextStyle(
    fontSize: 12.sp,
    fontWeight: FontWeight.normal,
    color: Colors.white54,
    height: 1.3,
  );

  static TextStyle overline = TextStyle(
    fontSize: 10.sp,
    fontWeight: FontWeight.w500,
    color: Colors.white54,
    height: 1.2,
    letterSpacing: 1.5,
  );

  // 辅助信息样式 - 用于年龄、国家、用户ID等次要信息
  static TextStyle auxiliary = TextStyle(
    fontSize: 9.sp,
    fontWeight: FontWeight.normal,
    color: Colors.white70,
    height: 1.2,
  );

  static TextStyle firstLabelStyle = TextStyle(
    fontSize: 22.sp,
    fontWeight: FontWeight.bold,
    fontFamily: saira,
    foreground: Paint()
      ..shader = LinearGradient(
        colors: [
          AppColors.mainGradientStart,
          AppColors.mainGradientEnd,
        ],
      ).createShader(
        Rect.fromLTWH(
          0.0,
          0.0,
          100.0,
          70.0,
        ),
      ),
  );

  static TextStyle firstUnselectedLabelStyle = TextStyle(
    fontSize: 20.sp,
    color: Colors.white70,
    fontFamily: saira,
  );

  static TextStyle secondLabelStyle = TextStyle(
    fontSize: 18.sp,
    fontWeight: FontWeight.bold,
    fontFamily: saira,
    foreground: Paint()
      ..shader = LinearGradient(
        colors: [
          AppColors.mainGradientStart,
          AppColors.mainGradientEnd,
        ],
      ).createShader(
        Rect.fromLTWH(
          0.0,
          0.0,
          100.0,
          70.0,
        ),
      ),
  );

  static TextStyle secondUnselectedLabelStyle = TextStyle(
    fontSize: 17.sp,
    fontWeight: FontWeight.normal,
    color: Colors.white70,
    fontFamily: saira,
  );
}
