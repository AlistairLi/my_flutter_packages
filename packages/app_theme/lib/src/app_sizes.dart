import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 用于改变 Widget 的大小
class AppSizes {
  AppSizes._();

  // 通用
  static double appBarBackSize = 40.w;
  static double emptyLayoutImageWidth = 150.w;
  static double emptyLayoutImageHeight = 150.w;

  // 个人中心
  static double mineAvatarSize = 88.w;
  static double mineItemHeight = 56.w;
  static double blockItemHeight = 88.w;
  static double settingItemHeight = 49.w;
  static double languageItemHeight = 49.w;

  // 消息中心
  static double followItemHeight = 88.w;

  // 充值弹窗
  static double rechargeDialogItemHeight = 64.w;

  // ============================================

  // 基础尺寸单位
  // static final double _baseUnit = 4.w;

  // ==========================================
  // 按钮尺寸
  // ==========================================

  // 按钮高度
  static double buttonHeightTiny = 28.w;
  static double buttonHeightSmall = 32.w;
  static double buttonHeightMedium = 40.w;
  static double buttonHeightLarge = 48.w;
  static double buttonHeightExtraLarge = 56.w;

  // 按钮最小宽度
  static double buttonMinWidthTiny = 64.w;
  static double buttonMinWidthSmall = 80.w;
  static double buttonMinWidthMedium = 120.w;
  static double buttonMinWidthLarge = 160.w;
  static double buttonMinWidthExtraLarge = 200.w;

  // ==========================================
  // 输入框尺寸
  // ==========================================

  // 输入框高度
  static double inputHeightSmall = 36.w;
  static double inputHeightMedium = 44.w;
  static double inputHeightLarge = 52.w;

  // 输入框最小宽度
  static double inputMinWidth = 200.w;

  // ==========================================
  // 头像尺寸
  // ==========================================

  static double avatarTiny = 24.w;
  static double avatarSmall = 32.w;
  static double avatarMedium = 48.w;
  static double avatarLarge = 64.w;
  static double avatarExtraLarge = 80.w;
  static double avatarHuge = 120.w;

  // ==========================================
  // 卡片尺寸
  // ==========================================

  // 卡片最小高度
  static double cardMinHeight = 80.w;

  // 卡片最大宽度
  static double cardMaxWidth = 400.w;

  // ==========================================
  // 工具栏尺寸
  // ==========================================

  // 应用栏高度
  static double appBarHeight = 56.w;

  // 底部导航栏高度
  static double bottomNavigationHeight = 56.w;

  // 工具栏高度
  static double toolbarHeight = 48.w;

  // ==========================================
  // 列表项尺寸
  // ==========================================

  // 列表项高度
  static double listItemHeightSmall = 48.w;
  static double listItemHeightMedium = 56.w;
  static double listItemHeightLarge = 64.w;

  // 列表项最小高度
  static double listItemMinHeight = 44.w;

  // ==========================================
  // 对话框尺寸
  // ==========================================

  // 对话框最小宽度
  static double dialogMinWidth = 280.w;

  // 对话框最大宽度
  static double dialogMaxWidth = 560.w;

  // ==========================================
  // 分割线尺寸
  // ==========================================

  static double dividerThickness = 0.5.w;
  static double dividerHeight = 1.w;

  // ==========================================
  // 进度条尺寸
  // ==========================================

  static double progressBarHeight = 4.w;
  static double progressBarHeightLarge = 8.w;

  // ==========================================
  // 开关尺寸
  // ==========================================

  static double switchWidth = 40.w;
  static double switchHeight = 20.w;

  // ==========================================
  // 滑块尺寸
  // ==========================================

  static double sliderHeight = 4.w;
  static double sliderThumbRadius = 8.w;

  // ==========================================
  // 预定义的尺寸配置
  // ==========================================

  // 按钮尺寸配置
  static Size buttonSizeTiny = Size(buttonMinWidthTiny, buttonHeightTiny);
  static Size buttonSizeSmall = Size(buttonMinWidthSmall, buttonHeightSmall);
  static Size buttonSizeMedium = Size(buttonMinWidthMedium, buttonHeightMedium);
  static Size buttonSizeLarge = Size(buttonMinWidthLarge, buttonHeightLarge);
  static Size buttonSizeExtraLarge =
      Size(buttonMinWidthExtraLarge, buttonHeightExtraLarge);

  // 输入框尺寸配置
  static Size inputSizeSmall = Size(inputMinWidth, inputHeightSmall);
  static Size inputSizeMedium = Size(inputMinWidth, inputHeightMedium);
  static Size inputSizeLarge = Size(inputMinWidth, inputHeightLarge);

  // 头像尺寸配置
  static Size avatarSizeTiny = Size(avatarTiny, avatarTiny);
  static Size avatarSizeSmall = Size(avatarSmall, avatarSmall);
  static Size avatarSizeMedium = Size(avatarMedium, avatarMedium);
  static Size avatarSizeLarge = Size(avatarLarge, avatarLarge);
  static Size avatarSizeExtraLarge = Size(avatarExtraLarge, avatarExtraLarge);
  static Size avatarSizeHuge = Size(avatarHuge, avatarHuge);

  // ==========================================
  // 响应式尺寸
  // ==========================================

  /// 根据屏幕宽度获取响应式按钮高度
  static double getResponsiveButtonHeight(double width) {
    if (width < 600) return buttonHeightMedium;
    if (width < 900) return buttonHeightLarge;
    return buttonHeightExtraLarge;
  }

  /// 根据屏幕宽度获取响应式输入框高度
  static double getResponsiveInputHeight(double width) {
    if (width < 600) return inputHeightMedium;
    if (width < 900) return inputHeightLarge;
    return inputHeightLarge;
  }

  /// 根据屏幕宽度获取响应式头像尺寸
  static double getResponsiveAvatarSize(double width) {
    if (width < 600) return avatarMedium;
    if (width < 900) return avatarLarge;
    return avatarExtraLarge;
  }

  // ==========================================
  // 尺寸配置类
  // ==========================================

  /// 获取按钮尺寸配置
  static ButtonSizeConfig getButtonSize(ButtonSize size) {
    switch (size) {
      case ButtonSize.tiny:
        return ButtonSizeConfig(
          height: buttonHeightTiny,
          minWidth: buttonMinWidthTiny,
        );
      case ButtonSize.small:
        return ButtonSizeConfig(
          height: buttonHeightSmall,
          minWidth: buttonMinWidthSmall,
        );
      case ButtonSize.medium:
        return ButtonSizeConfig(
          height: buttonHeightMedium,
          minWidth: buttonMinWidthMedium,
        );
      case ButtonSize.large:
        return ButtonSizeConfig(
          height: buttonHeightLarge,
          minWidth: buttonMinWidthLarge,
        );
      case ButtonSize.extraLarge:
        return ButtonSizeConfig(
          height: buttonHeightExtraLarge,
          minWidth: buttonMinWidthExtraLarge,
        );
    }
  }

  /// 获取输入框尺寸配置
  static InputSizeConfig getInputSize(InputSize size) {
    switch (size) {
      case InputSize.small:
        return InputSizeConfig(height: inputHeightSmall);
      case InputSize.medium:
        return InputSizeConfig(height: inputHeightMedium);
      case InputSize.large:
        return InputSizeConfig(height: inputHeightLarge);
    }
  }

  /// 获取头像尺寸配置
  static AvatarSizeConfig getAvatarSize(AvatarSize size) {
    switch (size) {
      case AvatarSize.tiny:
        return AvatarSizeConfig(size: avatarTiny);
      case AvatarSize.small:
        return AvatarSizeConfig(size: avatarSmall);
      case AvatarSize.medium:
        return AvatarSizeConfig(size: avatarMedium);
      case AvatarSize.large:
        return AvatarSizeConfig(size: avatarLarge);
      case AvatarSize.extraLarge:
        return AvatarSizeConfig(size: avatarExtraLarge);
      case AvatarSize.huge:
        return AvatarSizeConfig(size: avatarHuge);
    }
  }
}

// ==========================================
// 枚举定义
// ==========================================

enum ButtonSize { tiny, small, medium, large, extraLarge }

enum InputSize { small, medium, large }

enum AvatarSize { tiny, small, medium, large, extraLarge, huge }

// ==========================================
// 配置类
// ==========================================

class ButtonSizeConfig {
  final double height;
  final double minWidth;

  const ButtonSizeConfig({
    required this.height,
    required this.minWidth,
  });
}

class InputSizeConfig {
  final double height;

  const InputSizeConfig({
    required this.height,
  });
}

class AvatarSizeConfig {
  final double size;

  const AvatarSizeConfig({
    required this.size,
  });
}
