import 'package:auto_size_text_plus/auto_size_text_plus.dart';
import 'package:flutter/material.dart';

/// 通用文本
class AppText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool softWrap;

  /// 是否自动缩放文本
  final bool autoSize;

  /// 最小字体大小, 仅设置autoSize为true时生效
  /// minFontSize must be a multiple of stepGranularity.
  final double minFontSize;

  /// 最大字体大小, 仅设置autoSize为true时生效
  /// maxFontSize must be a multiple of stepGranularity
  final double maxFontSize;

  final double stepGranularity;

  final VoidCallback? onTap;

  /// 外边距设置 - 优先级：margin > horizontalMargin/verticalMargin > 具体方向margin
  ///
  /// 是否支持外边距设置, 默认为false
  final bool enableMargin;

  /// 最高优先级：同时设置四个方向的margin
  final double? margin;

  /// 第二优先级：水平/垂直方向的margin
  final double? marginHorizontal;
  final double? marginVertical;

  /// 第三优先级：具体方向的margin
  final double? marginLeft;
  final double? marginTop;
  final double? marginRight;
  final double? marginBottom;

  /// RTL支持：start/end margin（与left/right margin独立）
  final double? marginStart;
  final double? marginEnd;

  /// 内边距设置 - 优先级：padding > horizontalPadding/verticalPadding > 具体方向padding
  ///
  /// 是否支持内边距设置，默认为true
  final bool enablePadding;

  /// 最高优先级：同时设置四个方向的padding
  final double? padding;

  /// 第二优先级：水平/垂直方向的padding
  final double? paddingHorizontal;
  final double? paddingVertical;

  /// 第三优先级：具体方向的padding
  final double? paddingLeft;
  final double? paddingTop;
  final double? paddingRight;
  final double? paddingBottom;

  /// RTL支持：start/end padding（与left/right padding独立）
  final double? paddingStart;
  final double? paddingEnd;

  /// 弹性布局设置
  final int? flex;

  /// 弹性布局的Fit属性
  /// 如果设置为 FlexFit.tight，在Column中，会撑高
  final FlexFit? fit;

  const AppText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap = true,
    this.autoSize = true,
    this.minFontSize = 6,
    this.maxFontSize = double.infinity,
    this.stepGranularity = 1.0,
    this.onTap,
    // 外边距属性
    this.enableMargin = false,
    this.margin,
    this.marginHorizontal,
    this.marginVertical,
    this.marginLeft,
    this.marginTop,
    this.marginRight,
    this.marginBottom,
    this.marginStart,
    this.marginEnd,
    // 内边距属性
    this.enablePadding = true,
    this.padding,
    this.paddingHorizontal,
    this.paddingVertical,
    this.paddingLeft,
    this.paddingTop,
    this.paddingRight,
    this.paddingBottom,
    this.paddingStart,
    this.paddingEnd,
    this.flex,
    this.fit,
  });

  @override
  Widget build(BuildContext context) {
    Widget current = autoSize
        ? AutoSizeText(
            text,
            style: style,
            minFontSize: minFontSize,
            maxFontSize: maxFontSize,
            stepGranularity: stepGranularity,
            textAlign: textAlign,
            maxLines: maxLines,
            overflow: overflow,
            softWrap: softWrap,
          )
        : Text(
            text,
            style: style,
            textAlign: textAlign,
            maxLines: maxLines,
            overflow: overflow,
            softWrap: softWrap,
          );

    if (onTap != null) {
      current = GestureDetector(
        onTap: onTap,
        child: current,
      );
    }

    // 处理外边距设置
    if (enableMargin) {
      current = _applyMargin(current);
    }

    // 处理内边距设置
    if (enablePadding) {
      current = _applyPadding(current);
    }

    // 处理弹性布局
    if (fit != null) {
      current = Flexible(
        fit: fit!,
        flex: flex ?? 1,
        child: current,
      );
    }

    return current;
  }

  /// 应用外边距，按Android MarginLayoutParams的优先级逻辑
  Widget _applyMargin(Widget child) {
    // 最高优先级：margin（同时设置四个方向）
    if (margin != null) {
      return Container(
        margin: EdgeInsets.all(margin!),
        child: child,
      );
    }

    // 第二优先级：horizontalMargin 和 verticalMargin
    double? effectiveLeftMargin;
    double? effectiveRightMargin;
    double? effectiveTopMargin;
    double? effectiveBottomMargin;

    // 处理水平方向的margin
    if (marginHorizontal != null) {
      effectiveLeftMargin = marginHorizontal;
      effectiveRightMargin = marginHorizontal;
    } else {
      effectiveLeftMargin = marginLeft;
      effectiveRightMargin = marginRight;
    }

    // 处理垂直方向的margin
    if (marginVertical != null) {
      effectiveTopMargin = marginVertical;
      effectiveBottomMargin = marginVertical;
    } else {
      effectiveTopMargin = marginTop;
      effectiveBottomMargin = marginBottom;
    }

    // 检查是否有任何margin需要应用
    bool hasMargin = effectiveLeftMargin != null ||
        effectiveRightMargin != null ||
        effectiveTopMargin != null ||
        effectiveBottomMargin != null ||
        marginStart != null ||
        marginEnd != null;

    if (!hasMargin) {
      return child;
    }

    // 判断使用哪种EdgeInsets类型
    bool useDirectional = marginStart != null || marginEnd != null;
    bool hasLeftRightMargin =
        effectiveLeftMargin != null || effectiveRightMargin != null;

    // 如果设置了start/end margin，或者单独设置了left/right margin，使用EdgeInsetsDirectional
    if (useDirectional || hasLeftRightMargin) {
      return Container(
        margin: EdgeInsetsDirectional.only(
          start: marginStart ?? effectiveLeftMargin ?? 0,
          end: marginEnd ?? effectiveRightMargin ?? 0,
          top: effectiveTopMargin ?? 0,
          bottom: effectiveBottomMargin ?? 0,
        ),
        child: child,
      );
    } else {
      // 如果只设置了top/bottom margin，使用EdgeInsets
      return Container(
        margin: EdgeInsets.only(
          top: effectiveTopMargin ?? 0,
          bottom: effectiveBottomMargin ?? 0,
        ),
        child: child,
      );
    }
  }

  /// 应用内边距，按Android MarginLayoutParams的优先级逻辑
  Widget _applyPadding(Widget child) {
    // 最高优先级：padding（同时设置四个方向）
    if (padding != null) {
      return Padding(
        padding: EdgeInsets.all(padding!),
        child: child,
      );
    }

    // 第二优先级：horizontalPadding 和 verticalPadding
    double? effectiveLeftPadding;
    double? effectiveRightPadding;
    double? effectiveTopPadding;
    double? effectiveBottomPadding;

    // 处理水平方向的padding
    if (paddingHorizontal != null) {
      effectiveLeftPadding = paddingHorizontal;
      effectiveRightPadding = paddingHorizontal;
    } else {
      effectiveLeftPadding = paddingLeft;
      effectiveRightPadding = paddingRight;
    }

    // 处理垂直方向的padding
    if (paddingVertical != null) {
      effectiveTopPadding = paddingVertical;
      effectiveBottomPadding = paddingVertical;
    } else {
      effectiveTopPadding = paddingTop;
      effectiveBottomPadding = paddingBottom;
    }

    // 检查是否有任何padding需要应用
    bool hasPadding = effectiveLeftPadding != null ||
        effectiveRightPadding != null ||
        effectiveTopPadding != null ||
        effectiveBottomPadding != null ||
        paddingStart != null ||
        paddingEnd != null;

    if (!hasPadding) {
      return child;
    }

    // 判断使用哪种EdgeInsets类型
    bool useDirectional = paddingStart != null || paddingEnd != null;
    bool hasLeftRightPadding =
        effectiveLeftPadding != null || effectiveRightPadding != null;

    // 如果设置了start/end padding，或者单独设置了left/right padding，使用EdgeInsetsDirectional
    if (useDirectional || hasLeftRightPadding) {
      return Padding(
        padding: EdgeInsetsDirectional.only(
          start: paddingStart ?? effectiveLeftPadding ?? 0,
          end: paddingEnd ?? effectiveRightPadding ?? 0,
          top: effectiveTopPadding ?? 0,
          bottom: effectiveBottomPadding ?? 0,
        ),
        child: child,
      );
    } else {
      // 如果只设置了top/bottom padding，使用EdgeInsets
      return Padding(
        padding: EdgeInsets.only(
          top: effectiveTopPadding ?? 0,
          bottom: effectiveBottomPadding ?? 0,
        ),
        child: child,
      );
    }
  }
}
