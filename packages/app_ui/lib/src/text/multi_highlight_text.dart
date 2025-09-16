import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

/// 支持多个占位符替换的富文本组件
class MultiHighlightText extends StatelessWidget {
  final String template;
  final Map<String, String> variables;
  final Map<String, TextStyle>? highlightStyles;
  final Map<String, VoidCallback>? clickCallbacks;
  final TextStyle? defaultStyle;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;

  const MultiHighlightText({
    super.key,
    required this.template,
    required this.variables,
    this.highlightStyles,
    this.clickCallbacks,
    this.defaultStyle,
    this.maxLines,
    this.overflow,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    String processedText = template;
    final allReplacements = <String>[];

    // 替换变量
    for (final entry in variables.entries) {
      processedText = processedText.replaceAll(entry.key, entry.value);
      allReplacements.add(entry.value);
    }

    // 分割文本
    final parts = _splitTextWithReplacements(processedText, allReplacements);

    return Text.rich(
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
      TextSpan(
        children: parts.map((part) {
          if (allReplacements.contains(part)) {
            // 查找对应的样式
            final variableKey = variables.entries
                .firstWhere((entry) => entry.value == part)
                .key;
            final style =
                highlightStyles?[variableKey] ?? _getDefaultHighlightStyle();

            return TextSpan(
              text: part,
              style: style,
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  clickCallbacks?[variableKey]?.call();
                },
            );
          } else {
            return TextSpan(
              text: part,
              style: defaultStyle ?? _getDefaultStyle(),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  // do nothing
                },
            );
          }
        }).toList(),
      ),
    );
  }

  List<String> _splitTextWithReplacements(
      String text, List<String> replacements) {
    if (replacements.isEmpty) return [text];

    final pattern = RegExp(replacements.map((r) => RegExp.escape(r)).join('|'));
    final parts = text.split(pattern);
    final matches = pattern.allMatches(text);

    List<String> result = [];
    int partIndex = 0;

    for (final match in matches) {
      if (partIndex < parts.length) {
        result.add(parts[partIndex]);
      }
      result.add(match.group(0)!);
      partIndex++;
    }

    if (partIndex < parts.length) {
      result.add(parts[partIndex]);
    }

    return result.where((part) => part.isNotEmpty).toList();
  }

  TextStyle _getDefaultStyle() {
    return TextStyle(
      color: Color(0xFFFFFFFF),
      fontSize: 14,
    );
  }

  TextStyle _getDefaultHighlightStyle() {
    return TextStyle(
      color: Color(0xFFFFFFFF),
      fontSize: 14,
      fontWeight: FontWeight.bold,
    );
  }
}
