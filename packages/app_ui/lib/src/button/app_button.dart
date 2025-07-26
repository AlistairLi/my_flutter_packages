import 'package:flutter/material.dart';

enum AppButtonType { primary, secondary, outline, text }

/// 通用按钮
class AppButton extends StatelessWidget {
  final String? text;
  final VoidCallback? onPressed;
  final AppButtonType type;
  final bool isLoading;
  final bool isDisabled;
  final Widget? icon;
  final double? width;
  final double? height;

  const AppButton({
    super.key,
    this.text,
    this.onPressed,
    this.type = AppButtonType.primary,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null && !isDisabled && !isLoading;

    return SizedBox(
      width: width,
      height: height,
      child: _buildButton(isEnabled),
    );
  }

  Widget _buildButton(bool isEnabled) {
    switch (type) {
      case AppButtonType.primary:
        return ElevatedButton(
          onPressed: isEnabled ? onPressed : null,
          style: _getPrimaryStyle(),
          child: _buildChild(),
        );
      case AppButtonType.secondary:
        return ElevatedButton(
          onPressed: isEnabled ? onPressed : null,
          style: _getSecondaryStyle(),
          child: _buildChild(),
        );
      case AppButtonType.outline:
        return OutlinedButton(
          onPressed: isEnabled ? onPressed : null,
          style: _getOutlineStyle(),
          child: _buildChild(),
        );
      case AppButtonType.text:
        return TextButton(
          onPressed: isEnabled ? onPressed : null,
          style: _getTextStyle(),
          child: _buildChild(),
        );
    }
  }

  Widget _buildChild() {
    if (isLoading) {
      return SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            type == AppButtonType.primary ? Colors.white : Colors.blue,
          ),
        ),
      );
    }

    if (icon != null && text != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon!,
          SizedBox(width: 8),
          Text(text!),
        ],
      );
    }

    if (icon != null) {
      return icon!;
    }

    if (text != null) {
      return Text(text!);
    }

    return const SizedBox.shrink();
  }

  ButtonStyle _getPrimaryStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  ButtonStyle _getSecondaryStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.grey[200],
      foregroundColor: Colors.black87,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  ButtonStyle _getOutlineStyle() {
    return OutlinedButton.styleFrom(
      foregroundColor: Colors.blue,
      side: BorderSide(color: Colors.blue),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  ButtonStyle _getTextStyle() {
    return TextButton.styleFrom(
      foregroundColor: Colors.blue,
    );
  }
}
