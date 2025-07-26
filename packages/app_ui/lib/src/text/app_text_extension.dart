import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// 翻译文本
extension TranslateText on Text {
  Widget translate(Future<String>? future, {String? placeholder}) {
    return FutureBuilder<String>(
        future: future, // TODO  这里未测试
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          String response = placeholder ?? "...";
          if (snapshot.hasData) {
            response = snapshot.data!;
          }
          return finalText(response);
        });
  }

  Widget translateWithId(
    String messageKey, {
    Future<String>? future,
    String? cachedTranslationText,
    String? placeholder,
  }) {
    String? data = this.data;
    if (cachedTranslationText != null) {
      return finalText(cachedTranslationText);
    }

    return FutureBuilder<String>(
        future: future, // TODO  这里未测试
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          String response = placeholder ?? data ?? "";
          if (snapshot.hasData) {
            response = snapshot.data!;
          }
          if (kDebugMode) {
            print("翻译，显示内容  $response  ${snapshot.data}   ${snapshot.error}");
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox.shrink();
          } else if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return const SizedBox.shrink();
            } else {
              return finalText(response);
            }
          }
          throw "should not happen";
        });
  }

  Widget finalText(String text) {
    return Text(
      text,
      key: key,
      locale: locale,
      maxLines: maxLines,
      overflow: overflow,
      semanticsLabel: semanticsLabel,
      softWrap: softWrap,
      strutStyle: strutStyle,
      style: style,
      textAlign: textAlign,
      textDirection: textDirection,
      textHeightBehavior: textHeightBehavior,
      textScaleFactor: textScaleFactor,
      textWidthBasis: textWidthBasis,
    );
  }
}
