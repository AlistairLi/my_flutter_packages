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

  /// 文本方向
  final TextDirection? textDirection;

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
    this.textDirection,
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
            textDirection: textDirection,
          )
        : Text(
            text,
            style: style,
            textAlign: textAlign,
            maxLines: maxLines,
            overflow: overflow,
            softWrap: softWrap,
            textDirection: textDirection,
          );

    if (onTap != null) {
      current = GestureDetector(
        onTap: onTap,
        child: current,
      );
    }

    // 处理内边距设置（先 padding 再 margin，保证 margin 在最外层）
    if (enablePadding) {
      current = _applyPadding(current);
    }

    // 处理外边距设置（若有 margin 参数则默认启用）
    if (enableMargin || _hasAnyMargin()) {
      current = _applyMargin(current);
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
    final insets = _buildEdgeInsets(
      all: margin,
      horizontal: marginHorizontal,
      vertical: marginVertical,
      left: marginLeft,
      right: marginRight,
      top: marginTop,
      bottom: marginBottom,
      start: marginStart,
      end: marginEnd,
    );
    if (insets == null) return child;
    return Container(margin: insets, child: child);
  }

  bool _hasAnyMargin() {
    return margin != null ||
        marginHorizontal != null ||
        marginVertical != null ||
        marginLeft != null ||
        marginTop != null ||
        marginRight != null ||
        marginBottom != null ||
        marginStart != null ||
        marginEnd != null;
  }

  /// 应用内边距，按Android MarginLayoutParams的优先级逻辑
  Widget _applyPadding(Widget child) {
    final insets = _buildEdgeInsets(
      all: padding,
      horizontal: paddingHorizontal,
      vertical: paddingVertical,
      left: paddingLeft,
      right: paddingRight,
      top: paddingTop,
      bottom: paddingBottom,
      start: paddingStart,
      end: paddingEnd,
    );
    if (insets == null) return child;
    return Padding(padding: insets, child: child);
  }

  /// 按优先级构建 EdgeInsets：all > horizontal/vertical > 各方向；支持 start/end 用 EdgeInsetsDirectional
  static EdgeInsetsGeometry? _buildEdgeInsets({
    double? all,
    double? horizontal,
    double? vertical,
    double? left,
    double? right,
    double? top,
    double? bottom,
    double? start,
    double? end,
  }) {
    if (all != null) return EdgeInsets.all(all);
    final effectiveLeft = horizontal ?? left;
    final effectiveRight = horizontal ?? right;
    final effectiveTop = vertical ?? top;
    final effectiveBottom = vertical ?? bottom;
    final hasAny = effectiveLeft != null ||
        effectiveRight != null ||
        effectiveTop != null ||
        effectiveBottom != null ||
        start != null ||
        end != null;
    if (!hasAny) return null;
    final useDirectional = start != null || end != null;
    final hasLeftRight = effectiveLeft != null || effectiveRight != null;
    if (useDirectional || hasLeftRight) {
      return EdgeInsetsDirectional.only(
        start: start ?? effectiveLeft ?? 0,
        end: end ?? effectiveRight ?? 0,
        top: effectiveTop ?? 0,
        bottom: effectiveBottom ?? 0,
      );
    }
    return EdgeInsets.only(
      top: effectiveTop ?? 0,
      bottom: effectiveBottom ?? 0,
    );
  }
}
