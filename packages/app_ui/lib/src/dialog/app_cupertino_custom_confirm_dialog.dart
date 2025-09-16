import 'package:flutter/material.dart';

/// Cupertino style 确认弹窗，但不使用 CupertinoAlertDialog，定制化程度更高
class AppCupertinoCustomConfirmDialog extends StatelessWidget {
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
  final Color? backgroundColor;
  final Color? dividerColor;
  final double borderRadius;
  final EdgeInsetsGeometry? contentPadding;
  final EdgeInsetsGeometry? buttonPadding;
  final double? width;
  final double widthScaleFactor;
  final double textScaleFactor;
  final int titleMaxLines;
  final int contentMaxLines;

  const AppCupertinoCustomConfirmDialog({
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
    this.backgroundColor,
    this.dividerColor,
    this.borderRadius = 16.0,
    this.contentPadding,
    this.buttonPadding,
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
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: width ?? 300 * widthScaleFactor,
          decoration: BoxDecoration(
            color: backgroundColor ?? Colors.white,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: contentPadding ??
                    EdgeInsets.symmetric(
                      horizontal: 24 * widthScaleFactor,
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
              Container(
                height: 0.75 * widthScaleFactor,
                color: dividerColor ?? Colors.black26,
              ),
              SizedBox(
                height: 48 * widthScaleFactor,
                child: Row(
                  children: [
                    Expanded(
                      child: _DialogButton(
                        text: leftText ?? "",
                        onTap: () {
                          onLeftClose?.call(context);
                          onLeftTap?.call();
                        },
                        textStyle: leftTextStyle ??
                            theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.black54,
                              fontSize: 16 * textScaleFactor,
                            ),
                        padding: buttonPadding ??
                            EdgeInsets.symmetric(
                              horizontal: 18 * widthScaleFactor,
                            ),
                      ),
                    ),
                    Container(
                      width: 0.75 * widthScaleFactor,
                      color: dividerColor ?? Colors.black26,
                    ),
                    Expanded(
                      child: _DialogButton(
                        text: rightText ?? "",
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
                        padding: buttonPadding ??
                            EdgeInsets.symmetric(
                              horizontal: 18 * widthScaleFactor,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DialogButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry? padding;

  const _DialogButton({
    required this.text,
    this.onTap,
    this.textStyle,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.zero,
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        padding: padding,
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
