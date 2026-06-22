import 'dart:io';

import 'package:flutter/foundation.dart';

/// Crashlytics 错误过滤工具。
///
/// 过滤不需要上报到 Firebase Crashlytics 的常见非致命错误。
class CrashlyticsErrorFilter {
  /// 判断 Flutter 捕获到的异常是否可以跳过 Crashlytics 上报。
  ///
  /// 返回 true 表示该错误可直接忽略；
  /// 返回 false 表示保留上报，后续通过 Crashlytics 聚合分析。
  static bool shouldIgnoreFlutterError(FlutterErrorDetails details) {
    return _isIgnorableError(details.exception);
  }

  /// 判断是否属于可以忽略的错误。
  static bool _isIgnorableError(Object error) {
    final message = error.toString();
    final normalizedMessage = message.toLowerCase();

    return _isNetworkError(error, normalizedMessage) ||
        _isImageLoadingError(normalizedMessage) ||
        _isCommonFlutterNonFatalError(normalizedMessage);
  }

  /// 过滤网络相关错误。
  static bool _isNetworkError(Object error, String normalizedMessage) {
    if (error is SocketException) {
      return true;
    }

    // 添加规则时请使用小写
    const keywords = <String>[
      'no route to host',
      'connection refused',
      'failed host lookup',
      'connection reset by peer',
      'httpexception',
      'handshakeexception',
      'timeoutexception',
      'network is unreachable',
    ];

    return _containsAny(normalizedMessage, keywords);
  }

  /// 过滤图片加载相关错误。
  static bool _isImageLoadingError(String normalizedMessage) {
    // 添加规则时请使用小写
    const keywords = <String>[
      'failed to load image',
      'imagecodecexception',
      'invalid image data',
      'unable to decode bytes as an image',
      'invalid argument(s): string is not well-formed utf-16',
      'invalid image dimensions',
    ];

    return _containsAny(normalizedMessage, keywords);
  }

  /// 过滤 Flutter 常见非致命错误。
  static bool _isCommonFlutterNonFatalError(String normalizedMessage) {
    // 添加规则时请使用小写
    const keywords = <String>[
      // 'a renderflex overflowed',
      // 'a renderbox was not laid out',
      // 'duplicate globalkey detected in widget tree',
      // 'scrollcontroller attached to multiple scrollviews',
      // 'vertical viewport was given unbounded height',
      // 'horizontal viewport was given unbounded width',
      // 'nosuchmethoderror: the method',
      // 'rangeerror',
      // 'assert failed',
      'unhandled exception: missingpluginexception',
    ];

    return _containsAny(normalizedMessage, keywords);
  }

  /// 判断文本是否包含任意关键字。
  static bool _containsAny(String normalizedMessage,
      Iterable<String> keywords) {
    return keywords.any(normalizedMessage.contains);
  }
}
