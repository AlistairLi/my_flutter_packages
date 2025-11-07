import 'package:flutter/material.dart';

/// 自定义通用确认弹窗
class BottomConfirmDialog extends StatelessWidget {
  final String? title;
  final Widget? titleWidget;
  final String? content;
  final String? leftText;
  final String? rightText;
  final void Function(BuildContext context)? onLeftClose;
  final void Function(BuildContext context)? onRightClose;
  final VoidCallback? onLeftTap;
  final VoidCallback? onRightTap;
  final TextStyle? titleTextStyle;
  final TextStyle? contentTextStyle;
  final TextStyle? leftTextStyle;
  final TextStyle? rightTextStyle;
  final Border? leftBorder;
  final Border? rightBorder;
  final Color? leftBorderColor;
  final Color? rightBorderColor;
  final Color? backgroundColor;
  final Color? dividerColor;
  final BorderRadius? borderRadius;
  final Border? border;
  final double? buttonRadius;
  final double? buttonHeight;
  final EdgeInsetsGeometry? contentPadding;
  final double? width;
  final double widthScaleFactor;
  final double textScaleFactor;
  final int titleMaxLines;
  final int contentMaxLines;

  const BottomConfirmDialog({
    super.key,
    this.title,
    this.titleWidget,
    this.content,
    this.leftText = 'Cancel',
    this.rightText = 'Confirm',
    this.onLeftClose,
    this.onRightClose,
    this.onLeftTap,
    this.onRightTap,
    this.titleTextStyle,
    this.contentTextStyle,
    this.leftTextStyle,
    this.rightTextStyle,
    this.leftBorder,
    this.rightBorder,
    this.leftBorderColor,
    this.rightBorderColor,
    this.backgroundColor,
    this.dividerColor,
    this.borderRadius,
    this.border,
    this.buttonRadius,
    this.buttonHeight,
    this.contentPadding,
    this.width,
    this.widthScaleFactor = 1,
    this.textScaleFactor = 1,
    this.titleMaxLines = 3,
    this.contentMaxLines = 20,
  }) : assert(title != null || titleWidget != null || content != null,
            'The "title" and "content" cannot be used simultaneously.');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    var bottomBarHeight = MediaQuery.of(context).padding.bottom;
    return Material(
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.white,
          borderRadius: borderRadius,
          border: border,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: contentPadding ??
                  EdgeInsets.symmetric(
                    horizontal: 20 * widthScaleFactor,
                    vertical: 16 * widthScaleFactor,
                  ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (titleWidget != null) ...[
                    titleWidget!,
                    SizedBox(height: 12 * widthScaleFactor),
                  ],
                  if (titleWidget == null && title != null) ...[
                    Text(
                      title!,
                      maxLines: titleMaxLines,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: titleTextStyle ??
                          theme.textTheme.titleMedium?.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 18 * textScaleFactor,
                          ),
                    ),
                    SizedBox(height: 12 * widthScaleFactor),
                  ],
                  if (content != null) ...[
                    Text(
                      content!,
                      maxLines: contentMaxLines,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: contentTextStyle ??
                          theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.black87,
                            fontSize: 16 * textScaleFactor,
                          ),
                    ),
                  ],
                ],
              ),
            ),
            Row(
              children: [
                SizedBox(width: 20 * widthScaleFactor),
                Expanded(
                  child: _DialogButton(
                    height: buttonHeight ?? 48 * widthScaleFactor,
                    text: leftText ?? "",
                    backgroundColor: leftBorderColor,
                    border: leftBorder,
                    radius: buttonRadius,
                    onTap: () {
                      onLeftClose?.call(context);
                      onLeftTap?.call();
                    },
                    textStyle: leftTextStyle ??
                        theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.black54,
                          fontSize: 16 * textScaleFactor,
                        ),
                  ),
                ),
                SizedBox(width: 15 * widthScaleFactor),
                Expanded(
                  child: _DialogButton(
                    height: buttonHeight ?? 48 * widthScaleFactor,
                    text: rightText ?? "",
                    backgroundColor: rightBorderColor,
                    border: rightBorder,
                    radius: buttonRadius,
                    onTap: () {
                      onRightClose?.call(context);
                      onRightTap?.call();
                    },
                    textStyle: rightTextStyle ??
                        theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 16 * textScaleFactor,
                        ),
                  ),
                ),
                SizedBox(width: 20 * widthScaleFactor),
              ],
            ),
            SizedBox(height: 15 * widthScaleFactor),
            SizedBox(height: bottomBarHeight)
          ],
        ),
      ),
    );
  }
}

class _DialogButton extends StatelessWidget {
  final String text;
  final Color? backgroundColor;
  final Border? border;
  final VoidCallback? onTap;
  final TextStyle? textStyle;
  final double? radius;
  final double height;

  const _DialogButton({
    required this.text,
    required this.height,
    this.backgroundColor,
    this.border,
    this.onTap,
    this.textStyle,
    this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: height,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 13),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: border,
          borderRadius: BorderRadius.circular(radius ?? 0),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            text,
            maxLines: 1,
            style: textStyle,
          ),
        ),
      ),
    );
  }
}
