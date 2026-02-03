// packages/shared_widgets/lib/src/layout/app_container.dart
import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

/// 通用容器组件
///
/// 特性：
/// - 如果 [child] 是 [Text]、[AppText] 或 [RichText]，并且未设置 [alignment]，
///   则文本会自动居中显示。
/// - 当 [child] 是 [Text]、[AppText] 或 [RichText]，会自动包裹 [Padding]，若未指定 [textPadding]，
///   则根据容器宽度或 [widthScaleFactor] 自动计算左右边距。
/// - 可通过 [useFittedBox] 控制是否为上述文本子组件使用 FittedBox，默认不使用。
/// - 支持 [decorationImage] 设置背景图。
/// - 支持 [topRadius]/[bottomRadius] 分别设置顶部、底部左右圆角。
/// - 当同时使用 [decorationImage] 与圆角且 [clipBehavior] 为 [Clip.none] 时，会改为 [Clip.antiAlias] 以正确裁剪背景图。
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
  /// 优先级：borderRadius > topRadius/bottomRadius > radius > 无圆角
  final BorderRadiusGeometry? borderRadius;
  final double? radius;

  /// 顶部左右圆角（同时设置 topLeft、topRight）
  final double? topRadius;

  /// 底部左右圆角（同时设置 bottomLeft、bottomRight）
  final double? bottomRadius;

  /// 是否设置为圆形
  final bool circular;

  /// BoxDecoration 背景图
  final DecorationImage? decorationImage;

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

  /// 是否需要点击防抖动
  final bool debounceTap;
  final double widthScaleFactor;

  /// 是否自动居中文本类型的子组件
  /// 当 child 是 Text、AppText 或 RichText 时，如果未设置 alignment，是否自动居中
  final bool autoCenterText;

  /// 当 child 为 Text/AppText/RichText 时是否使用 FittedBox 包裹（默认不使用）
  final bool useFittedBox;

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
    this.topRadius,
    this.bottomRadius,
    this.circular = false,
    this.decorationImage,
    this.clipBehavior = Clip.none,
    this.childBorderRadius,
    this.childRadius,
    this.childCircular = false,
    this.childClipBehavior = Clip.antiAlias,
    this.border,
    this.boxShadow,
    this.alignment,
    this.onTap,
    this.debounceTap = true,
    this.widthScaleFactor = 1.0,
    this.autoCenterText = true,
    this.useFittedBox = false,
  });

  @override
  Widget build(BuildContext context) {
    final actualWidth = size ?? width;
    final actualHeight = size ?? height;
    final borderRadiusValue = circular ? null : _buildBorderRadius();
    // 有背景图且带圆角时需裁剪，否则背景图会画出圆角外
    final effectiveClipBehavior = (decorationImage != null &&
            borderRadiusValue != null &&
            clipBehavior == Clip.none)
        ? Clip.antiAlias
        : clipBehavior;

    Widget current = Container(
      width: actualWidth,
      height: actualHeight,
      constraints: _buildConstraints(),
      padding: _applyPadding(),
      margin: _applyMargin(),
      alignment: _buildAlignment(),
      clipBehavior: effectiveClipBehavior,
      decoration: BoxDecoration(
        color: gradient == null ? color : null,
        gradient: gradient,
        image: decorationImage,
        shape: circular ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: borderRadiusValue,
        border: border,
        boxShadow: boxShadow,
      ),
      child: _buildChild(),
    );

    if (onTap != null) {
      if (debounceTap) {
        current = DebouncedTapWidget(
          onTap: onTap,
          child: current,
        );
      } else {
        current = AppGestureDetector(
          onTap: onTap,
          child: current,
        );
      }
    }
    return current;
  }

  /// 应用外边距，优先级：margin > horizontal/vertical > 具体方向
  EdgeInsetsGeometry? _applyMargin() => _buildEdgeInsets(
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

  /// 应用内边距，优先级：padding > horizontal/vertical > 具体方向
  EdgeInsetsGeometry? _applyPadding() => _buildEdgeInsets(
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

  /// 构建对齐方式
  AlignmentGeometry? _buildAlignment() {
    // 如果用户明确设置了 alignment，优先使用
    if (alignment != null) {
      return alignment!;
    }

    // 如果启用了自动居中文本且 child 是文本类型，自动居中
    if (autoCenterText &&
        (child is Text || child is AppText || child is RichText)) {
      return Alignment.center;
    }

    return null;
  }

  /// 构建圆角设置
  BorderRadiusGeometry? _buildBorderRadius() {
    // 优先级：borderRadius > topRadius/bottomRadius > radius > 无圆角
    if (borderRadius != null) {
      return borderRadius;
    }
    if (topRadius != null || bottomRadius != null) {
      return BorderRadius.only(
        topLeft: Radius.circular(topRadius ?? 0),
        topRight: Radius.circular(topRadius ?? 0),
        bottomLeft: Radius.circular(bottomRadius ?? 0),
        bottomRight: Radius.circular(bottomRadius ?? 0),
      );
    }
    if (radius != null) {
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
      final padding = textPadding ??
          EdgeInsets.symmetric(
            horizontal: (actualWidth != null &&
                    !actualWidth.isInfinite &&
                    !actualWidth.isNaN)
                ? (actualWidth * 0.1)
                : (5 * widthScaleFactor),
          );
      result = Padding(
        padding: padding,
        child: useFittedBox
            ? FittedBox(
                fit: BoxFit.scaleDown,
                alignment: alignment ?? Alignment.center,
                child: result,
              )
            : result,
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
