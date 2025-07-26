import 'package:flutter/cupertino.dart';

/// Cupertino style 的底部操作表，使用 CupertinoActionSheet
/// 🔶[UNTESTED]
class AppCupertinoActionSheet extends StatelessWidget {
  final String? title;
  final String? message;
  final List<AppIOSActionSheetAction> actions;
  final AppIOSActionSheetAction? cancelAction;

  const AppCupertinoActionSheet({
    super.key,
    this.title,
    this.message,
    required this.actions,
    this.cancelAction,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoActionSheet(
      title: title != null ? Text(title!) : null,
      message: message != null ? Text(message!) : null,
      actions: _buildActions(context),
      cancelButton: _buildCancelButton(context),
    );
  }

  List<CupertinoActionSheetAction> _buildActions(BuildContext context) {
    return actions.map((action) {
      return CupertinoActionSheetAction(
        onPressed: () {
          Navigator.of(context).pop();
          action.onPressed?.call();
        },
        isDestructiveAction: action.isDestructive,
        child: Text(
          action.text,
          style: TextStyle(
            fontSize: 16,
            color: action.isDestructive
                ? CupertinoColors.destructiveRed
                : CupertinoColors.activeBlue,
          ),
        ),
      );
    }).toList();
  }

  CupertinoActionSheetAction? _buildCancelButton(BuildContext context) {
    if (cancelAction == null) return null;

    return CupertinoActionSheetAction(
      onPressed: () {
        Navigator.of(context).pop();
        cancelAction!.onPressed?.call();
      },
      child: Text(
        cancelAction!.text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: CupertinoColors.label,
        ),
      ),
    );
  }

  /// 显示底部操作表
  static Future<T?> show<T>({
    required BuildContext context,
    String? title,
    String? message,
    required List<AppIOSActionSheetAction> actions,
    AppIOSActionSheetAction? cancelAction,
  }) {
    return showCupertinoModalPopup<T>(
      context: context,
      builder: (context) => AppCupertinoActionSheet(
        title: title,
        message: message,
        actions: actions,
        cancelAction: cancelAction,
      ),
    );
  }
}

/// iOS底部操作表操作按钮
class AppIOSActionSheetAction {
  final String text;
  final VoidCallback? onPressed;
  final bool isDestructive;

  const AppIOSActionSheetAction({
    required this.text,
    this.onPressed,
    this.isDestructive = false,
  });
}
