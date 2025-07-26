import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:http_util/src/controller/request_loading_controller.dart';

typedef HeaderBuilder = Map<String, String> Function();
// typedef ResponseDataProcessor = Map<String, dynamic> Function(dynamic rawData);

/// 默认的响应数据预处理，支持 String 和 Map 两种格式
Map<String, dynamic> defaultResponseDataProcessor(dynamic rawData) {
  if (rawData is String) {
    return jsonDecode(rawData) as Map<String, dynamic>;
  } else if (rawData is Map<String, dynamic>) {
    return rawData;
  } else {
    throw Exception('Unexpected response data format');
  }
}

class NetworkConfig {
  final String baseUrl;
  final Duration sendTimeout;
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final String contentType;
  final ResponseType responseType;
  final Map<String, dynamic> Function()? headersBuilder;
  final bool enableLogging;

  /// 提供原始 JSON 预处理（String 转 Map 等）,建议在业务层处理
  // final ResponseDataProcessor responseDataProcessor;

  // 指定包装函数：T 是数据模型类型，返回值是项目的响应数据结构，例如 ApiResponse<T>
  final dynamic Function<T>(dynamic rawData, T Function(dynamic data) fromJson)
      responseWrapper;
  final dynamic Function<T>(dynamic rawData) responseWrapper2;

  /// 异常回调（可用于展示 toast / 记录错误）
  final void Function(Object error, StackTrace stack)? onException;

  /// 业务层的业务错误处理回调
  final void Function<R>(R response, bool isShowToast, String path)?
      businessErrorHandler;

  // 用于排除日志打印的接口 path 列表（支持字符串或正则）
  final List<Pattern> excludeLogPaths;

  // loading 回调
  final RequestLoadingController? loadingController;

  const NetworkConfig({
    required this.baseUrl,
    this.sendTimeout = const Duration(seconds: 10),
    this.connectTimeout = const Duration(seconds: 10),
    this.receiveTimeout = const Duration(seconds: 10),
    this.contentType = Headers.jsonContentType,
    this.responseType = ResponseType.json,
    this.headersBuilder,
    this.enableLogging = true,
    // this.responseDataProcessor = defaultResponseDataProcessor,
    required this.responseWrapper,
    required this.responseWrapper2,
    this.onException,
    this.businessErrorHandler,
    this.excludeLogPaths = const [],
    this.loadingController,
  });
}
