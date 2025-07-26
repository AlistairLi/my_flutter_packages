import 'package:flutter/cupertino.dart';

/// Cupertino style 的通用弹窗，使用 CupertinoAlertDialog
/// 🔶[UNTESTED]
class AppCupertinoDialog extends StatelessWidget {
  final String? title;
  final TextStyle? titleStyle;
  final Widget? titleWidget;
  final String? content;
  final TextStyle? contentStyle;
  final Widget? contentWidget;
  final List<AppIOSDialogAction> actions;
  final bool barrierDismissible;
  final EdgeInsetsGeometry? contentPadding;
  final double? maxWidth;
  final double? maxHeight;

  const AppCupertinoDialog({
    super.key,
    this.title,
    this.titleStyle,
    this.titleWidget,
    this.content,
    this.contentStyle,
    this.contentWidget,
    required this.actions,
    this.barrierDismissible = true,
    this.contentPadding,
    this.maxWidth,
    this.maxHeight,
  }) : assert(content == null || contentWidget == null,
            'The "content" and "contentWidget" cannot be used simultaneously.');

  @override
  Widget build(BuildContext context) {
    return CupertinoTheme(
      data: CupertinoThemeData(
        brightness: Brightness.light,
      ),
      child: CupertinoAlertDialog(
        title: _buildTitle(),
        content: _buildContent(),
        actions: _buildActions(context),
      ),
    );
  }

  Widget _buildTitle() {
    if (titleWidget != null) {
      return titleWidget!;
    }
    if (title != null) {
      return Text(
        title!,
        style: titleStyle ??
            const TextStyle(
              fontSize: 17.0,
              color: CupertinoColors.label,
            ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildContent() {
    if (contentWidget != null) {
      return Padding(
        padding: contentPadding ?? EdgeInsets.only(top: 8),
        child: contentWidget!,
      );
    }

    if (content != null) {
      return Padding(
        padding: contentPadding ?? EdgeInsets.only(top: 8),
        child: Text(
          content!,
          style: contentStyle ??
              TextStyle(
                fontSize: 14,
                color: CupertinoColors.label,
                height: 1.4,
              ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  List<CupertinoDialogAction> _buildActions(BuildContext context) {
    return actions.map((action) {
      return CupertinoDialogAction(
        onPressed: () {
          _dismiss(context);
          action.onPressed?.call();
        },
        isDefaultAction: action.isDefault,
        isDestructiveAction: action.isDestructive,
        child: Text(
          action.text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: action.isDefault ? FontWeight.w600 : FontWeight.normal,
            color: action.isDestructive
                ? CupertinoColors.destructiveRed
                : (action.isDefault
                    ? CupertinoColors.activeBlue
                    : CupertinoColors.label),
          ),
        ),
      );
    }).toList();
  }

  void _dismiss(BuildContext context) {
    Navigator.of(context).pop();
  }

  /// 显示弹窗
  static Future<T?> show<T>({
    required BuildContext context,
    String? title,
    Widget? titleWidget,
    String? content,
    Widget? contentWidget,
    required List<AppIOSDialogAction> actions,
    bool barrierDismissible = true,
    EdgeInsetsGeometry? contentPadding,
    double? maxWidth,
    double? maxHeight,
  }) {
    return showCupertinoDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => AppCupertinoDialog(
        title: title,
        titleWidget: titleWidget,
        content: content,
        contentWidget: contentWidget,
        actions: actions,
        barrierDismissible: barrierDismissible,
        contentPadding: contentPadding,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
      ),
    );
  }

  /// 显示确认弹窗
  static Future<bool> showConfirm({
    required BuildContext context,
    String? title,
    required String content,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDestructive = false,
    VoidCallback? onConfirm,
  }) async {
    final result = await show<bool>(
      context: context,
      title: title,
      content: content,
      actions: [
        AppIOSDialogAction(
          text: cancelText,
          onPressed: () {},
        ),
        AppIOSDialogAction(
          text: confirmText,
          isDefault: true,
          isDestructive: isDestructive,
          onPressed: onConfirm,
        ),
      ],
    );
    return result ?? false;
  }

  /// 显示警告弹窗
  static Future<void> showAlert({
    required BuildContext context,
    String? title,
    required String content,
    String buttonText = 'Confirm',
  }) {
    return show(
      context: context,
      title: title,
      content: content,
      actions: [
        AppIOSDialogAction(
          text: buttonText,
          isDefault: true,
          onPressed: () {},
        ),
      ],
    );
  }

  /// 显示选择弹窗
  static Future<String?> showSelection({
    required BuildContext context,
    String? title,
    required List<String> options,
    String cancelText = 'Confirm',
  }) async {
    final result = await show<String>(
      context: context,
      title: title,
      contentWidget: Column(
        mainAxisSize: MainAxisSize.min,
        children: options
            .map(
              (option) => CupertinoDialogAction(
                onPressed: () => Navigator.of(context).pop(option),
                child: Text(
                  option,
                  style: TextStyle(
                    fontSize: 16,
                    color: CupertinoColors.label,
                  ),
                ),
              ),
            )
            .toList(),
      ),
      actions: [
        AppIOSDialogAction(
          text: cancelText,
          onPressed: () {},
        ),
      ],
    );
    return result;
  }
}

/// iOS弹窗操作按钮
class AppIOSDialogAction {
  final String text;
  final VoidCallback? onPressed;
  final bool isDefault;
  final bool isDestructive;

  const AppIOSDialogAction({
    required this.text,
    this.onPressed,
    this.isDefault = false,
    this.isDestructive = false,
  });
}
