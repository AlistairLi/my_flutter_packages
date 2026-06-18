import 'package:flutter/foundation.dart';

/// Crashlytics 错误过滤工具。
///
/// 这里只过滤由网络、设备网络栈或远端资源状态引起的瞬时错误。
class CrashlyticsErrorFilter {
  /// 判断 Flutter 捕获到的异常是否可以跳过 Crashlytics 上报。
  ///
  /// 返回 true 表示该错误大概率不是客户端代码缺陷，直接忽略；
  /// 返回 false 表示保留上报，后续通过 Crashlytics 聚合分析。
  static bool shouldIgnoreFlutterError(FlutterErrorDetails details) {
    return _isIgnorableInfrastructureError(details.exception);
  }

  /// 判断是否属于可以忽略的基础设施类错误。
  ///
  /// 注意：不要在这里加入 RangeError、NoSuchMethodError、MissingPluginException
  /// 等宽泛关键字，这些通常能暴露业务逻辑、数据解析或集成问题。
  static bool _isIgnorableInfrastructureError(Object error) {
    final message = error.toString().toLowerCase();
    return _isTransientNetworkMessage(message) ||
        _isIgnorableNetworkImageLoadMessage(message);
  }

  /// 通过错误文本识别明确的网络瞬时失败。
  static bool _isTransientNetworkMessage(String message) {
    const keywords = <String>[
      'failed host lookup',
      'connection closed while receiving data',
      'connection terminated during handshake',
      'software caused connection abort',
      'socketexception',
      'handshakeexception',
      'tlsexception',
      'cronet exception',
      'err_address_unreachable',
      'network is unreachable',
      'connection reset by peer',
      'timed out',
      'no address associated with hostname',
    ];

    const wrappedNetworkKeywords = <String>[
      'clientexception',
      'dioexception',
      'httpexception',
    ];
    const wrappedNetworkFailureKeywords = <String>[
      'connection timeout',
      'send timeout',
      'receive timeout',
      'connection error',
      'connection failed',
      'connection refused',
      'network error',
    ];

    return _containsAny(message, keywords) ||
        (_containsAny(message, wrappedNetworkKeywords) &&
            _containsAny(message, wrappedNetworkFailureKeywords));
  }

  /// 只忽略由网络导致的远端图片加载失败。
  ///
  /// ImageCodecException、Invalid image data、Unable to decode bytes as an image
  /// 这类解码错误不直接过滤，因为它们可能暴露资源损坏、缓存污染或本地资源配置错误。
  static bool _isIgnorableNetworkImageLoadMessage(String message) {
    if (!message.contains('failed to load image')) {
      return false;
    }

    const imageNetworkKeywords = <String>[
      'http exception',
      'socketexception',
      'failed host lookup',
      'connection',
      'timed out',
      'statuscode: 404',
      'statuscode: 403',
      'statuscode: 500',
      'statuscode: 502',
      'statuscode: 503',
      'statuscode: 504',
    ];

    return _containsAny(message, imageNetworkKeywords);
  }

  /// 判断文本是否包含任意关键字。
  static bool _containsAny(String message, Iterable<String> keywords) {
    return keywords.any(message.contains);
  }
}
