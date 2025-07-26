// packages/shared_widgets/lib/src/layout/app_container.dart
import 'package:app_ui/shared_widgets.dart';
import 'package:flutter/material.dart';

/// 通用容器组件
///
/// 特性：
/// - 如果 [child] 是 [Text]、[AppText] 或 [RichText]，并且未设置 [alignment]，
///   则文本会自动居中显示。
/// - 当 [child] 是 [Text]、[AppText] 或 [RichText]，会自动包裹 [Padding]，若未指定 [textPadding]，
///   则根据容器宽度或 [widthScaleFactor] 自动计算左右边距。
///   TODO 添加对设置背景图片的支持
class AppContainer extends StatelessWidget {
  final Widget? child;
  final double? width;
  final double? height;

  /// 同时设置宽高（当宽高相等时使用）
  final double? size;

  /// 最小最大宽高设置
  final double? minWidth;
  final double? maxWidth;
  final double? minHeight;
  final double? maxHeight;

  final Color? color;
  final Gradient? gradient;
  final AlignmentGeometry? alignment;

  /// 外边距设置 - 优先级：margin > horizontalMargin/verticalMargin > 具体方向margin
  ///
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

  final EdgeInsetsGeometry? textPadding;

  /// 圆角设置
  /// 优先级：borderRadius > radius > 无圆角
  final BorderRadiusGeometry? borderRadius;
  final double? radius;

  /// 是否设置为圆形
  final bool circular;

  /// 子组件的裁剪行为
  /// - Clip.none: 不裁剪
  /// - Clip.hardEdge: 硬边裁剪
  /// - Clip.antiAlias: 抗锯齿裁剪
  /// - Clip.antiAliasWithSaveLayer: 抗锯齿裁剪并保存图层
  final Clip childClipBehavior;

  /// 子组件的圆角设置
  /// 优先级：childBorderRadius > childRadius > 无圆角
  final BorderRadius? childBorderRadius;
  final double? childRadius;

  /// 子组件是否设置为圆形
  final bool childCircular;

  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;
  final Clip clipBehavior;
  final VoidCallback? onTap;
  final double widthScaleFactor;

  /// 是否自动居中文本类型的子组件
  /// 当 child 是 Text、AppText 或 RichText 时，如果未设置 alignment，是否自动居中
  final bool autoCenterText;

  const AppContainer({
    super.key,
    this.child,
    this.width,
    this.height,
    this.size,
    this.minWidth,
    this.maxWidth,
    this.minHeight,
    this.maxHeight,
    // 外边距属性
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
    this.padding,
    this.paddingHorizontal,
    this.paddingVertical,
    this.paddingLeft,
    this.paddingTop,
    this.paddingRight,
    this.paddingBottom,
    this.paddingStart,
    this.paddingEnd,
    this.textPadding,
    this.color,
    this.gradient,
    this.borderRadius,
    this.radius,
    this.circular = false,
    this.clipBehavior = Clip.none,
    this.childBorderRadius,
    this.childRadius,
    this.childCircular = false,
    this.childClipBehavior = Clip.antiAlias,
    this.border,
    this.boxShadow,
    this.alignment,
    this.onTap,
    this.widthScaleFactor = 1.0,
    this.autoCenterText = true,
  });

  @override
  Widget build(BuildContext context) {
    // 处理 size 属性
    final actualWidth = size ?? width;
    final actualHeight = size ?? height;

    Widget current = Container(
      width: actualWidth,
      height: actualHeight,
      constraints: _buildConstraints(),
      padding: _applyPadding(),
      margin: _applyMargin(),
      alignment: _buildAlignment(),
      clipBehavior: clipBehavior,
      decoration: BoxDecoration(
        color: gradient == null ? color : null,
        gradient: gradient,
        shape: circular ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: circular ? null : _buildBorderRadius(),
        border: border,
        boxShadow: boxShadow,
      ),
      child: _buildChild(),
    );

    if (onTap != null) {
      current = AppGestureDetector(
        onTap: onTap,
        child: current,
      );
    }
    return current;
  }

  /// 应用外边距，按Android MarginLayoutParams的优先级逻辑
  EdgeInsetsGeometry? _applyMargin() {
    // 最高优先级：margin（同时设置四个方向）
    if (margin != null) {
      return EdgeInsets.all(margin!);
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
      return null;
    }

    // 判断使用哪种EdgeInsets类型
    bool useDirectional = marginStart != null || marginEnd != null;
    bool hasLeftRightMargin =
        effectiveLeftMargin != null || effectiveRightMargin != null;

    // 如果设置了start/end margin，或者单独设置了left/right margin，使用EdgeInsetsDirectional
    if (useDirectional || hasLeftRightMargin) {
      return EdgeInsetsDirectional.only(
        start: marginStart ?? effectiveLeftMargin ?? 0,
        end: marginEnd ?? effectiveRightMargin ?? 0,
        top: effectiveTopMargin ?? 0,
        bottom: effectiveBottomMargin ?? 0,
      );
    } else {
      // 如果只设置了top/bottom margin，使用EdgeInsets
      return EdgeInsets.only(
        top: effectiveTopMargin ?? 0,
        bottom: effectiveBottomMargin ?? 0,
      );
    }
  }

  /// 应用内边距，按Android MarginLayoutParams的优先级逻辑
  EdgeInsetsGeometry? _applyPadding() {
    // 最高优先级：padding（同时设置四个方向）
    if (padding != null) {
      return EdgeInsets.all(padding!);
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
      return null;
    }

    // 判断使用哪种EdgeInsets类型
    bool useDirectional = paddingStart != null || paddingEnd != null;
    bool hasLeftRightPadding =
        effectiveLeftPadding != null || effectiveRightPadding != null;

    // 如果设置了start/end padding，或者单独设置了left/right padding，使用EdgeInsetsDirectional
    if (useDirectional || hasLeftRightPadding) {
      return EdgeInsetsDirectional.only(
        start: paddingStart ?? effectiveLeftPadding ?? 0,
        end: paddingEnd ?? effectiveRightPadding ?? 0,
        top: effectiveTopPadding ?? 0,
        bottom: effectiveBottomPadding ?? 0,
      );
    } else {
      // 如果只设置了top/bottom padding，使用EdgeInsets
      return EdgeInsets.only(
        top: effectiveTopPadding ?? 0,
        bottom: effectiveBottomPadding ?? 0,
      );
    }
  }

  /// 构建对齐方式
  AlignmentGeometry? _buildAlignment() {
    // 如果用户明确设置了 alignment，优先使用
    if (alignment != null) {
      return alignment!;
    }

    // 如果启用了自动居中文本且 child 是文本类型，自动居中
    if (autoCenterText && (child is Text || child is AppText || child is RichText)) {
      return Alignment.center;
    }

    return null;
  }

  /// 构建圆角设置
  BorderRadiusGeometry? _buildBorderRadius() {
    // 优先级：borderRadius > radius > 无圆角
    if (borderRadius != null) {
      return borderRadius;
    } else if (radius != null) {
      return BorderRadius.circular(radius!);
    }
    return null;
  }

  /// 构建约束条件
  BoxConstraints? _buildConstraints() {
    final actualWidth = size ?? width;
    final actualHeight = size ?? height;

    double? minW = minWidth;
    double? maxW = maxWidth;
    double? minH = minHeight;
    double? maxH = maxHeight;

    // 如果设置了固定宽高，需要与最小最大宽高协调
    if (actualWidth != null) {
      if (minW != null && actualWidth < minW) {
        minW = actualWidth;
      }
      if (maxW != null && actualWidth > maxW) {
        maxW = actualWidth;
      }
    }

    if (actualHeight != null) {
      if (minH != null && actualHeight < minH) {
        minH = actualHeight;
      }
      if (maxH != null && actualHeight > maxH) {
        maxH = actualHeight;
      }
    }

    // 只有当设置了最小或最大约束时才返回 BoxConstraints
    if (minW != null || maxW != null || minH != null || maxH != null) {
      return BoxConstraints(
        minWidth: minW ?? 0,
        maxWidth: maxW ?? double.infinity,
        minHeight: minH ?? 0,
        maxHeight: maxH ?? double.infinity,
      );
    }

    return null;
  }

  Widget? _buildChild() {
    if (child == null) {
      return child;
    }

    Widget result = child!;

    if (childCircular) {
      result = ClipOval(
        clipBehavior: childClipBehavior,
        child: result,
      );
    } else {
      // 处理子组件的圆角
      final childRadius = _buildChildBorderRadius();
      if (childRadius != null) {
        result = ClipRRect(
          borderRadius: childRadius,
          clipBehavior: childClipBehavior,
          child: result,
        );
      }
    }

    if (child is Text || child is AppText || child is RichText) {
      final actualWidth = size ?? width;
      return Padding(
        padding: textPadding ??
            EdgeInsets.symmetric(
              horizontal: (actualWidth != null &&
                      !actualWidth.isInfinite &&
                      !actualWidth.isNaN)
                  ? (actualWidth * 0.1)
                  : (5 * widthScaleFactor),
            ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: alignment ?? Alignment.center,
          child: result,
        ),
      );
    }

    return result;
  }

  /// 构建子组件的圆角设置
  BorderRadius? _buildChildBorderRadius() {
    // 优先级：childBorderRadius > childRadius > 无圆角
    if (childBorderRadius != null) {
      return childBorderRadius;
    } else if (childRadius != null) {
      return BorderRadius.circular(childRadius!);
    }
    return null;
  }
}
