import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppSpacing {
  AppSpacing._();

  // 基础间距单位
  static final double _baseUnit = 4.w;

  // 微小间距
  static double xs = _baseUnit; // 4
  static double sm = _baseUnit * 2; // 8
  static double md = _baseUnit * 3; // 12
  static double lg = _baseUnit * 4; // 16
  static double xl = _baseUnit * 6; // 24
  static double xxl = _baseUnit * 8; // 32
  static double xxxl = _baseUnit * 12; // 48

  // 常用间距
  static double paddingTiny = xs;
  static double paddingSmall = sm;
  static double paddingMedium = md;
  static double paddingLarge = lg;
  static double paddingExtraLarge = xl;
  static double paddingHuge = xxl;

  // 边距
  static double marginTiny = xs;
  static double marginSmall = sm;
  static double marginMedium = md;
  static double marginLarge = lg;
  static double marginExtraLarge = xl;
  static double marginHuge = xxl;

  // 圆角
  static double radiusTiny = 2.w;
  static double radiusSmall = 4.w;
  static double radiusMedium = 8.w;
  static double radiusLarge = 12.w;
  static double radiusExtraLarge = 16.w;
  static double radiusHuge = 24.w;
  static double radiusCircular = 50.w;

  // 边框宽度
  static double borderTiny = 0.5.w;
  static double borderSmall = 1.w;
  static double borderMedium = 2.w;
  static double borderLarge = 3.w;

  // 阴影
  static double elevationTiny = 1.w;
  static double elevationSmall = 2.w;
  static double elevationMedium = 4.w;
  static double elevationLarge = 8.w;
  static double elevationExtraLarge = 16.w;

  // 常用 EdgeInsets
  static EdgeInsets paddingAllTiny = EdgeInsets.all(paddingTiny);
  static EdgeInsets paddingAllSmall = EdgeInsets.all(paddingSmall);
  static EdgeInsets paddingAllMedium = EdgeInsets.all(paddingMedium);
  static EdgeInsets paddingAllLarge = EdgeInsets.all(paddingLarge);
  static EdgeInsets paddingAllExtraLarge = EdgeInsets.all(paddingExtraLarge);

  static EdgeInsets paddingHorizontalTiny =
      EdgeInsets.symmetric(horizontal: paddingTiny);
  static EdgeInsets paddingHorizontalSmall =
      EdgeInsets.symmetric(horizontal: paddingSmall);
  static EdgeInsets paddingHorizontalMedium =
      EdgeInsets.symmetric(horizontal: paddingMedium);
  static EdgeInsets paddingHorizontalLarge =
      EdgeInsets.symmetric(horizontal: paddingLarge);
  static EdgeInsets paddingHorizontalExtraLarge =
      EdgeInsets.symmetric(horizontal: paddingExtraLarge);

  static EdgeInsets paddingVerticalTiny =
      EdgeInsets.symmetric(vertical: paddingTiny);
  static EdgeInsets paddingVerticalSmall =
      EdgeInsets.symmetric(vertical: paddingSmall);
  static EdgeInsets paddingVerticalMedium =
      EdgeInsets.symmetric(vertical: paddingMedium);
  static EdgeInsets paddingVerticalLarge =
      EdgeInsets.symmetric(vertical: paddingLarge);
  static EdgeInsets paddingVerticalExtraLarge =
      EdgeInsets.symmetric(vertical: paddingExtraLarge);

  // 常用 BorderRadius
  static BorderRadius radiusTinyAll =
      BorderRadius.all(Radius.circular(radiusTiny));
  static BorderRadius radiusSmallAll =
      BorderRadius.all(Radius.circular(radiusSmall));
  static BorderRadius radiusMediumAll =
      BorderRadius.all(Radius.circular(radiusMedium));
  static BorderRadius radiusLargeAll =
      BorderRadius.all(Radius.circular(radiusLarge));
  static BorderRadius radiusExtraLargeAll =
      BorderRadius.all(Radius.circular(radiusExtraLarge));
  static BorderRadius radiusHugeAll =
      BorderRadius.all(Radius.circular(radiusHuge));
}
