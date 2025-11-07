import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

/// 底部选择弹窗列表项的配置类
class AppBottomSheetItemConfig {
  /// 列表项背景色
  final Color? itemBackgroundColor;

  /// 列表项边框
  final Border? itemBorder;

  /// 列表项圆角
  final BorderRadius? itemBorderRadius;

  /// 列表项字体样式
  final TextStyle? itemTextStyle;

  /// 列表项宽度
  final double? itemWidth;

  /// 列表项高度
  final double? itemHeight;

  /// 列表项内边距
  final EdgeInsetsGeometry? itemPadding;

  const AppBottomSheetItemConfig({
    this.itemBackgroundColor = Colors.transparent,
    this.itemBorder,
    this.itemBorderRadius,
    this.itemTextStyle,
    this.itemWidth,
    this.itemHeight,
    this.itemPadding,
  });
}

/// 底部选择弹窗
class AppBottomSheet extends StatelessWidget {
  final List<String> labels;
  final void Function(int index, String label) onTap;
  final String? cancelText;
  final TextStyle? cancelTextStyle;

  /// 背景色
  final Color? backgroundColor;

  /// 边框
  final Border? border;

  /// 圆角
  final BorderRadius? borderRadius;

  /// 弹窗内边距
  final EdgeInsetsGeometry? padding;

  /// 是否显示取消按钮
  final bool pickCancel;

  /// 分割线颜色
  final Color? dividerColor;

  /// 分割线高度
  final double? dividerHeight;

  /// 分割线水平内边距
  final double? dividerPaddingHorizontal;

  /// 取消按钮分割线
  final Widget? cancelDivider;

  final double widthScaleFactor;
  final double textScaleFactor;
  final ValueChanged<BuildContext>? onClose;
  final ValueChanged<BuildContext>? onCancel;

  /// 列表项配置
  final AppBottomSheetItemConfig? itemConfig;

  const AppBottomSheet({
    super.key,
    required this.labels,
    required this.onTap,
    required this.widthScaleFactor,
    required this.textScaleFactor,
    this.cancelText,
    this.cancelTextStyle,
    this.pickCancel = true,
    this.dividerColor,
    this.dividerHeight,
    this.dividerPaddingHorizontal,
    this.cancelDivider,
    this.backgroundColor,
    this.border,
    this.borderRadius,
    this.padding,
    this.onClose,
    this.onCancel,
    this.itemConfig,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    List<Widget> listWidget = [];
    var divider = Divider(
      height: dividerHeight ?? 0.5 * textScaleFactor,
      thickness: dividerHeight ?? 0.5 * textScaleFactor,
      color: dividerColor ?? Colors.black26,
      indent: dividerPaddingHorizontal ?? 25 * widthScaleFactor,
      endIndent: dividerPaddingHorizontal ?? 25 * widthScaleFactor,
    );

    List<Widget> labelWidgets = List.generate(labels.length, (index) {
      return DebouncedTapWidget(
        onTap: () {
          onClose?.call(context);
          onTap(index, labels[index]);
        },
        child: Column(
          children: [
            Container(
              width: itemConfig?.itemWidth ?? double.infinity,
              height: itemConfig?.itemHeight ?? 54 * widthScaleFactor,
              alignment: Alignment.center,
              padding: itemConfig?.itemPadding,
              decoration: BoxDecoration(
                color: itemConfig?.itemBackgroundColor,
                border: itemConfig?.itemBorder,
                borderRadius: itemConfig?.itemBorderRadius,
              ),
              child: AppText(
                labels[index],
                maxLines: 2,
                textAlign: TextAlign.center,
                paddingHorizontal: 25 * widthScaleFactor,
                style: itemConfig?.itemTextStyle ??
                    theme.textTheme.titleMedium?.copyWith(
                      color: Colors.black87,
                      fontSize: 16 * textScaleFactor,
                    ),
              ),
            ),
            if (index < labels.length - 1) divider,
          ],
        ),
      );
    });
    listWidget.addAll(labelWidgets);

    if (pickCancel) {
      listWidget.add(cancelDivider ?? divider);
      listWidget.add(
        GestureDetector(
          child: Container(
            height: 60 * widthScaleFactor,
            alignment: Alignment.center,
            child: AppText(
              (cancelText ?? "Cancel"),
              maxLines: 2,
              textAlign: TextAlign.center,
              paddingHorizontal: 25 * widthScaleFactor,
              style: cancelTextStyle ??
                  theme.textTheme.titleMedium?.copyWith(
                    color: Colors.black54,
                    fontSize: 16 * textScaleFactor,
                  ),
            ),
          ),
          behavior: HitTestBehavior.opaque,
          onTap: () {
            onCancel?.call(context);
          },
        ),
      );
    }

    listWidget.add(sizedBoxHeight(MediaQuery.of(context).padding.bottom));

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: borderRadius,
        border: border,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: listWidget,
      ),
    );
  }
}
