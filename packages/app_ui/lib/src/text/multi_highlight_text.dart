import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

/// 支持多个占位符替换的富文本组件,包括文本、图片。
///
/// 用于显示包含多个可点击高亮区域的富文本，常用于协议文本、提示信息等场景
///
/// 示例：
/// ```dart
/// MultiHighlightText(
///   template: '我已阅读并同意《XXX》和《YYY》',
///   variables: {
///     'XXX': '用户协议',
///     'YYY': '隐私政策',
///   },
///   highlightStyles: {
///     'XXX': TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
///     'YYY': TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
///   },
///   clickCallbacks: {
///     'XXX': () => openUserAgreement(),
///     'YYY': () => openPrivacyPolicy(),
///   },
/// )
/// ```
class MultiHighlightText extends StatelessWidget {
  /// 文本模板，包含占位符（如 'XXX', 'YYY'）
  ///
  /// 模板中的占位符会被 [variables] 中对应的值替换
  ///
  /// 示例：
  /// - `'我已阅读并同意《XXX》和《YYY》'`
  /// - `'XXX YYY'`
  /// - `'每分钟 XXX 积分'`
  final String template;

  /// 变量映射表，键为占位符名称，值为实际要显示的文本
  ///
  /// 键名通常使用大写字母组合（如 'XXX', 'YYY', 'AAA' 等）
  /// 值为替换后的实际文本内容
  ///
  /// 示例：
  /// ```dart
  /// {
  ///   'XXX': '用户协议',
  ///   'YYY': '隐私政策',
  /// }
  /// ```
  final Map<String, String> variables;

  /// 高亮样式映射表，键对应 [variables] 中的键名
  ///
  /// 为每个变量指定特定样式，如果不提供则使用默认高亮样式
  /// 建议设置与普通文本不同的颜色以突出显示
  ///
  /// 示例：
  /// ```dart
  /// {
  ///   'XXX': TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
  ///   'YYY': TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
  /// }
  /// ```
  final Map<String, TextStyle>? highlightStyles;

  /// 点击回调映射表，键对应 [variables] 中的键名
  ///
  /// 当用户点击对应的高亮文本时触发回调
  /// 常用于打开链接、弹窗等操作
  ///
  /// 示例：
  /// ```dart
  /// {
  ///   'XXX': () => launchUrl(userAgreementUrl),
  ///   'YYY': () => launchUrl(privacyPolicyUrl),
  /// }
  /// ```
  final Map<String, VoidCallback>? clickCallbacks;

  /// 默认文本样式（非高亮部分）
  ///
  /// 如果不提供，将使用系统默认样式（白色，14px）
  /// 建议根据整体 UI 设计设置统一的字体样式
  final TextStyle? defaultStyle;

  /// 最大显示行数
  ///
  /// 超过此行数时会根据 [overflow] 参数进行截断
  /// 常用值：2-6 行
  final int? maxLines;

  /// 文本溢出处理方式
  final TextOverflow? overflow;

  /// 文本对齐方式
  final TextAlign? textAlign;

  /// 行内组件与文本之间的自动间距（横向）
  final double inlineWidgetSpacing;

  /// 行内组件的垂直对齐方式
  ///
  /// - [PlaceholderAlignment.baseline]: 基线对齐
  /// - [PlaceholderAlignment.middle]: 居中对齐
  final PlaceholderAlignment inlineWidgetAlignment;

  /// 基线对齐时使用的文本基线
  ///
  /// 仅当 [inlineWidgetAlignment] 为 [PlaceholderAlignment.baseline] 时生效。
  final TextBaseline inlineWidgetBaseline;

  /// 行内组件映射表，键为模板中的占位符，值为要插入的组件
  ///
  /// 适用于在富文本指定位置插入图片、图标等场景。
  ///
  /// 示例：
  /// ```dart
  /// template: '[icon] 我已阅读并同意《XXX》',
  /// inlineWidgets: {
  ///   '[icon]': Image.asset('assets/icon.png', width: 16, height: 16),
  /// }
  /// ```
  final Map<String, Widget>? inlineWidgets;

  /// 文本前插入的行内组件
  ///
  /// 当不方便在 [template] 中声明占位符时，可以直接使用前置组件。
  final Widget? leadingWidget;

  /// 文本后插入的行内组件
  ///
  /// 当不方便在 [template] 中声明占位符时，可以直接使用后置组件。
  final Widget? trailingWidget;

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
    this.inlineWidgetSpacing = 4,
    this.inlineWidgetAlignment = PlaceholderAlignment.middle,
    this.inlineWidgetBaseline = TextBaseline.alphabetic,
    this.inlineWidgets,
    this.leadingWidget,
    this.trailingWidget,
  });

  @override
  Widget build(BuildContext context) {
    final pieces = <_InlinePiece>[];

    if (leadingWidget != null) {
      pieces.add(_InlinePiece.widget(_buildWidgetSpan(leadingWidget!)));
    }

    pieces.addAll(_buildInlinePieces());

    if (trailingWidget != null) {
      pieces.add(_InlinePiece.widget(_buildWidgetSpan(trailingWidget!)));
    }

    final spans = _applyWidgetSpacing(pieces);

    return Text.rich(
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
      TextSpan(children: spans),
    );
  }

  List<_InlinePiece> _buildInlinePieces() {
    final tokens = <String>[
      ...variables.keys,
      ...(inlineWidgets?.keys ?? const <String>[]),
    ];

    if (tokens.isEmpty) {
      return [
        _InlinePiece.text(
          TextSpan(text: template, style: defaultStyle ?? _getDefaultStyle()),
        ),
      ];
    }

    // 长占位符优先，避免短占位符截断长占位符。
    tokens.sort((a, b) => b.length.compareTo(a.length));
    final pattern = RegExp(
      tokens.map((token) => RegExp.escape(token)).join('|'),
    );

    final pieces = <_InlinePiece>[];
    int start = 0;

    for (final match in pattern.allMatches(template)) {
      if (match.start > start) {
        final text = template.substring(start, match.start);
        if (text.isNotEmpty) {
          pieces.add(
            _InlinePiece.text(
              TextSpan(text: text, style: defaultStyle ?? _getDefaultStyle()),
            ),
          );
        }
      }

      final token = match.group(0)!;
      final inlineWidget = inlineWidgets?[token];

      if (inlineWidget != null) {
        pieces.add(_InlinePiece.widget(_buildWidgetSpan(inlineWidget)));
      } else {
        final text = variables[token] ?? token;
        final style = highlightStyles?[token] ?? _getDefaultHighlightStyle();
        final callback = clickCallbacks?[token];

        if (text.isNotEmpty) {
          pieces.add(
            _InlinePiece.text(
              TextSpan(
                text: text,
                style: style,
                recognizer: callback == null
                    ? null
                    : (TapGestureRecognizer()..onTap = callback),
              ),
            ),
          );
        }
      }

      start = match.end;
    }

    if (start < template.length) {
      final text = template.substring(start);
      if (text.isNotEmpty) {
        pieces.add(
          _InlinePiece.text(
            TextSpan(text: text, style: defaultStyle ?? _getDefaultStyle()),
          ),
        );
      }
    }

    return pieces;
  }

  WidgetSpan _buildWidgetSpan(Widget child) {
    return WidgetSpan(
      child: child,
      alignment: inlineWidgetAlignment,
      baseline: inlineWidgetBaseline,
    );
  }

  List<InlineSpan> _applyWidgetSpacing(List<_InlinePiece> pieces) {
    if (inlineWidgetSpacing <= 0 || pieces.isEmpty) {
      return pieces.map((piece) => piece.span).toList();
    }

    final spans = <InlineSpan>[];

    for (int i = 0; i < pieces.length; i++) {
      final current = pieces[i];
      spans.add(current.span);

      if (i == pieces.length - 1) {
        continue;
      }

      final next = pieces[i + 1];
      final shouldInsertSpacing =
          (current.isWidget && next.isText) ||
          (current.isText && next.isWidget);

      if (shouldInsertSpacing) {
        spans.add(
          WidgetSpan(
            child: SizedBox(width: inlineWidgetSpacing),
            alignment: inlineWidgetAlignment,
            baseline: inlineWidgetBaseline,
          ),
        );
      }
    }

    return spans;
  }

  TextStyle _getDefaultStyle() {
    return TextStyle(color: Color(0xFFFFFFFF), fontSize: 14);
  }

  TextStyle _getDefaultHighlightStyle() {
    return TextStyle(
      color: Color(0xFFFFFFFF),
      fontSize: 14,
      fontWeight: FontWeight.bold,
    );
  }
}

class _InlinePiece {
  final InlineSpan span;
  final bool isWidget;
  final bool isText;

  const _InlinePiece._(
    this.span, {
    required this.isWidget,
    required this.isText,
  });

  factory _InlinePiece.widget(InlineSpan span) {
    return _InlinePiece._(span, isWidget: true, isText: false);
  }

  factory _InlinePiece.text(InlineSpan span) {
    return _InlinePiece._(span, isWidget: false, isText: true);
  }
}
