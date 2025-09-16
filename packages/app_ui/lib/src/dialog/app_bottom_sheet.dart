import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

/// 底部选择弹窗
class AppBottomSheet extends StatelessWidget {
  final List<String> labels;
  final TextStyle? labelTextStyle;
  final void Function(int index, String label) onTap;
  final String? cancelText;
  final TextStyle? cancelTextStyle;

  /// 背景色
  final Color? backgroundColor;

  final double? topRadius;

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

  const AppBottomSheet({
    super.key,
    required this.labels,
    required this.onTap,
    required this.widthScaleFactor,
    required this.textScaleFactor,
    this.labelTextStyle,
    this.cancelText,
    this.cancelTextStyle,
    this.pickCancel = true,
    this.dividerColor,
    this.dividerHeight,
    this.dividerPaddingHorizontal,
    this.cancelDivider,
    this.backgroundColor,
    this.topRadius,
    this.onClose,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    List<Widget> listWidget = [];
    listWidget.add(sizedBoxHeight(10 * widthScaleFactor));

    var divider = Divider(
      height: dividerHeight ?? 0.5 * textScaleFactor,
      thickness: dividerHeight ?? 0.5 * textScaleFactor,
      color: dividerColor ?? Colors.black26,
      indent: dividerPaddingHorizontal ?? 25 * widthScaleFactor,
      endIndent: dividerPaddingHorizontal ?? 25 * widthScaleFactor,
    );

    List<Widget> labelWidgets = List.generate(labels.length, (index) {
      return AppGestureDetector(
        onTap: () {
          onClose?.call(context);
          onTap(index, labels[index]);
        },
        child: Column(
          children: [
            Container(
              height: 56 * widthScaleFactor,
              alignment: Alignment.center,
              child: AppText(
                labels[index],
                maxLines: 2,
                textAlign: TextAlign.center,
                paddingHorizontal: 25 * widthScaleFactor,
                style: labelTextStyle ??
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

    listWidget.add(
      sizedBoxHeight(MediaQuery.of(context).padding.bottom),
    );

    return Material(
      color: backgroundColor ?? Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusDirectional.only(
          topStart: Radius.circular(
            topRadius ?? (12 * widthScaleFactor),
          ),
          topEnd: Radius.circular(
            topRadius ?? (12 * widthScaleFactor),
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: listWidget,
      ),
    );
  }
}
