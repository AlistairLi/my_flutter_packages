import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_text_styles.dart';

class AppTheme {
  AppTheme._();

  // 亮色主题
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primarySwatch: Colors.blue,
      scaffoldBackgroundColor: AppColors.primaryBackground,

      // 文本主题
      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayLarge,
        displayMedium: AppTextStyles.displayMedium,
        displaySmall: AppTextStyles.displaySmall,
        headlineLarge: AppTextStyles.headlineLarge,
        headlineMedium: AppTextStyles.headlineMedium,
        headlineSmall: AppTextStyles.headlineSmall,
        titleLarge: AppTextStyles.titleLarge,
        titleMedium: AppTextStyles.titleMedium,
        titleSmall: AppTextStyles.titleSmall,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        bodySmall: AppTextStyles.bodySmall,
        labelLarge: AppTextStyles.labelLarge,
        labelMedium: AppTextStyles.labelMedium,
        labelSmall: AppTextStyles.labelSmall,
      ),

      // 应用栏主题
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primaryBackground,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.titleLarge,
      ),

      // 底部导航栏主题
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.bottomNavigatorColor,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white54,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // 卡片主题
      cardTheme: CardTheme(
        color: AppColors.primaryBackground,
        elevation: AppSpacing.elevationSmall,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.radiusMediumAll,
        ),
        margin: AppSpacing.paddingAllSmall,
      ),

      // 按钮主题
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          textStyle: AppTextStyles.labelLarge,
          padding: AppSpacing.paddingHorizontalLarge +
              AppSpacing.paddingVerticalMedium,
          shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.radiusMediumAll,
          ),
          elevation: AppSpacing.elevationSmall,
        ),
      ),

      // 输入框主题
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white10,
        border: OutlineInputBorder(
          borderRadius: AppSpacing.radiusMediumAll,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppSpacing.radiusMediumAll,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppSpacing.radiusMediumAll,
          borderSide: BorderSide(
            color: Colors.blue,
            width: AppSpacing.borderMedium,
          ),
        ),
        contentPadding: AppSpacing.paddingAllMedium,
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: Colors.white54),
      ),

      // 对话框主题
      dialogTheme: DialogTheme(
        backgroundColor: AppColors.primaryBackground,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.radiusLargeAll,
        ),
        titleTextStyle: AppTextStyles.titleMedium,
        contentTextStyle: AppTextStyles.bodyMedium,
      ),

      // 分割线主题
      dividerTheme: DividerThemeData(
        color: Colors.white24,
        thickness: 0.5,
        space: AppSpacing.marginMedium,
      ),
    );
  }

  // 暗色主题（与亮色主题相同，因为应用本身就是暗色主题）
  static ThemeData get darkTheme => lightTheme;

  // 获取当前主题
  static ThemeData getTheme(Brightness brightness) {
    return brightness == Brightness.light ? lightTheme : darkTheme;
  }
}
