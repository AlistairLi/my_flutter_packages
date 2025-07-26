import 'package:flutter/material.dart';

/// lijian
class AppText2 extends StatelessWidget {
  final String? text;
  final Color? color;
  final double? fontSize;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final FontWeight? fontWeight;
  final double? textStyleHeight;
  final TextDecoration? textDecoration;
  final TextStyle? textStyle;
  final String? fontFamily;
  final Color? decorationColor;
  final TextDecorationStyle? textDecorationStyle;
  final FontStyle? textFontStyle;

  const AppText2({
    super.key,
    this.textFontStyle,
    this.text,
    this.color = const Color(0xFF404040),
    this.fontSize,
    this.fontWeight,
    this.fontFamily,
    this.textStyleHeight = 1.4,
    this.textStyle,
    this.textAlign,
    this.maxLines,
    this.decorationColor,
    this.textDecorationStyle,
    this.overflow = TextOverflow.ellipsis,
    this.textDecoration,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text ?? "",
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
      style: textStyle ??
          TextStyle(
            fontWeight: fontWeight,
            fontSize: fontSize,
            color: color,
            fontStyle: textFontStyle,
            decoration: textDecoration,
            height: textStyleHeight,
            decorationColor: decorationColor,
            decorationStyle: textDecorationStyle,
          ),
    );
  }
}
