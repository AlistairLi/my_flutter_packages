import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // 主色调
  static const Color primary = Color(0xFF944CFF);
  static const Color primaryLight = Color(0xFF64B5F6);
  static const Color primaryDark = Color(0xFF1976D2);

  // 白色
  static const Color white = Color(0xFFFFFFFF);
  static const Color white90 = Color(0xE6FFFFFF);
  static const Color white80 = Color(0xCCFFFFFF);
  static const Color white70 = Color(0xB3FFFFFF);
  static const Color white60 = Color(0x99FFFFFF);
  static const Color white50 = Color(0x80FFFFFF);
  static const Color white40 = Color(0x66FFFFFF);
  static const Color white30 = Color(0x4DFFFFFF);
  static const Color white20 = Color(0x33FFFFFF);
  static const Color white15 = Color(0x26FFFFFF);
  static const Color white10 = Color(0x1AFFFFFF);
  static const Color white05 = Color(0x0DFFFFFF);

  // 黑色
  static const Color black = Color(0xFF000000);
  static const Color black90 = Color(0xE6000000);
  static const Color black80 = Color(0xCC000000);
  static const Color black70 = Color(0xB3000000);
  static const Color black60 = Color(0x99000000);
  static const Color black50 = Color(0x80000000);
  static const Color black40 = Color(0x66000000);
  static const Color black30 = Color(0x4D000000);
  static const Color black20 = Color(0x33000000);
  static const Color black15 = Color(0x26000000);
  static const Color black10 = Color(0x1A000000);
  static const Color black05 = Color(0x0D000000);
  static const Color transparent = Color(0x00000000);

  // 文本颜色
  static const Color textPrimary = white; // 主要文字颜色
  static const Color textSecondary = white90; // 次要文字颜色
  static const Color textTertiary = white60; // 第三层级文字颜色
  static const Color textDisabled = Color(0xFF666666); // 禁用状态文字颜色
  static const Color textHint = Colors.white38; // 提示文字颜色
  static const Color textLink = Color(0xFF3F51B5); // 超链接文字颜色
  static const Color textError = Color(0xFFF44336); // 错误状态文字颜色
  static const Color textOnPrimary = Colors.white; // 在 primary 背景上的文字颜色
  static const Color textOnBackground = Colors.white; // 在背景色上的主要文字
  static const Color textYellow = Color.fromRGBO(255, 230, 0, 1);
  static const Color textPurple = Color(0xFFFF19FB);

  // 状态颜色
  static const Color success = Color(0xff10DC60);
  static const Color info = Color(0xff33B5E5);
  static const Color warning = Color(0xffFFBB33);
  static const Color error = Color(0xffF04141);

  // 边框颜色
  static const Color borderLight = Color(0xFF404040);
  static const Color borderMedium = Color(0xFF606060);
  static const Color borderDark = Color(0xFF808080);

  // 分割线颜色
  static const Color divider = Color(0xFF404040);
  static const Color dividerLight = Color(0xFF524D6C);
  static const Color dividerDark = Color(0xFF1C192C);

  // 阴影颜色
  static const Color shadow = Color(0x1A000000);
  static const Color shadowLight = Color(0x0D000000);

  // 透明度颜色
  static Color overlay = Colors.black54;
  static Color overlayLight = Colors.black38;
  static Color overlayDark = Colors.black.withValues(alpha: 0.7);

  // 渐变色
  static const Color mainGradientStart = Color(0xFF994BFF);
  static const Color mainGradientEnd = Color(0xFFFF19FB);
  static const Color secondaryGradientStart = Color(0xFF3A3759);
  static const Color secondaryGradientEnd = Color(0xFF2D2B4A);

  // 输入框颜色
  static const Color inputCursor = Colors.white70; // 指针颜色，与背景对比明显
  static const Color inputFill = Color(0xFF3A3759); // 输入框填充色
  static const Color inputBorder = borderDark; // 输入框边框颜色
  static const Color inputHint = textHint; // 输入框提示文字颜色

  // 主题相关颜色
  /// 主背景色
  static const Color primaryBackground = Color(0xFF020001);

  /// 用于显示textPrimary文字的背景色
  static const Color backgroundForTextPrimary = Colors.black54;

  /// 首页底部导航栏背景色
  static const Color bottomNavigatorColor = primaryBackground;

  /// 通用确认弹窗背景色
  static const Color commonDialogBackgroundColor = Color(0xFF1F173E);

  /// appBar 背景色
  static const Color appBarBackgroundColor =
      Color.fromRGBO(255, 255, 255, 0.05);

  // ****** 功能模块 ******

  /// 启动页
  static const Color splashBackground = Color(0xFF020001);

  // 个人中心
  static const Color mineItemBgColor = Color(0xFF0F0C1B);
  static const Color blockItemBgColor = Color.fromRGBO(255, 255, 255, 0.05);
  static const Color settingItemBgColor = Color.fromRGBO(255, 255, 255, 0.05);
  static const Color languageDividerColor = Color(0xFF07060C);

  /// 主播墙
  static const Color secondLabelColor = Color(0xFF944CFF);
  static const Color secondUnselectedLabelColor = Colors.white12;
  static const Color regionChooseBgColor = Color(0xFF28263D);
  static const Color regionChooseItemBgColor = Color(0x26FFFFFF);

  // 主播详情页
  static const Color detailFemaleBackground = Color(0xFFFF79AC);
  static const Color detailCountryBackground = Color(0xFF8246FF);
  static const Color detailBottomBackground = Color(0xFF2B2442);

  // IM 会话列表
  static const Color conversationTopBackground =
      Color.fromRGBO(255, 255, 255, 0.05);
  static const Color conversationPinBackground = Colors.green;
  static const Color conversationDeleteBackground = Colors.red;
  static const Color chatLeftBundleBg = Color.fromRGBO(255, 255, 255, 0.15);
  static const Color chatRightBundleBg = Color(0xFF8046FF);

  // 礼物
  static const Color giftDialogBackground = Color(0xFF1C1927);

  // 充值
  static const Color rechargeBackground = commonDialogBackgroundColor;
  static const Color rechargeItemBackground = Color(0xFF1E1A32);
  static const Color rechargeDiscount = Color(0xFFB06BFF);
  static const Color rechargeDiscountBackground =
      Color.fromRGBO(176, 107, 255, 0.15);
  static const Color rechargeTagBackground = Color.fromRGBO(252, 53, 74, 1);

  // 三方支付
  static const Color payChannelBackground = Color(0xFF28263D);
  static const Color payChannelBlockBackground = Color(0xFF1C192C);

  // 机器人客服
  static const Color robotItemBackground = Color(0xFF373546);
  static const Color robotHighlight = textYellow;
  static const Color robotText = textSecondary;
  static const Color robotNotReview = textTertiary;
  static const Color robotReviewed = textYellow;
}
