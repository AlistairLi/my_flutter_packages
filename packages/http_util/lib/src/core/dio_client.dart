import 'package:dio/dio.dart';
import 'package:http_util/src/core/network_config.dart';
import 'package:http_util/src/interceptors/error_interceptor.dart';
import 'package:http_util/src/interceptors/header_interceptor.dart';

class DioClient {
  late final Dio _dio;
  final NetworkConfig _config;
  CancelToken? _cancelToken;

  CancelToken get cancelToken {
    // TODO 会不会有并发问题
    _cancelToken ??= CancelToken();
    return _cancelToken!;
  }

  DioClient(this._config) {
    _dio = Dio(BaseOptions(
      baseUrl: _config.baseUrl,
      sendTimeout: _config.sendTimeout,
      connectTimeout: _config.connectTimeout,
      receiveTimeout: _config.receiveTimeout,
    ));

    if (_config.headersBuilder != null) {
      _dio.interceptors.add(HeaderInterceptor(_config.headersBuilder));
    }

    if (_config.enableLogging) {
      _dio.interceptors.add(
        LogInterceptor(responseBody: true),
      );
      //
      // _dio.interceptors.add(
      //   PrettyDioLogger(
      //     requestHeader: true,
      //     requestBody: true,
      //     responseBody: true,
      //     error: true,
      //     compact: true,
      //     maxWidth: 800,
      //     filter: (options, args) {
      //       final path = options.path;
      //       return !_config.excludeLogPaths.any(
      //         (pattern) => pattern.matchAsPrefix(path) != null,
      //       );
      //     },
      //   ),
      // );
    }

    _dio.interceptors.add(ErrorInterceptor(_config.onException));
  }

  void addInterceptor(Interceptor interceptor) {
    _dio.interceptors.add(interceptor);
  }

  Future<R> post<T, R>(
    String path, {
    dynamic data,
    T Function(dynamic data)? fromJsonT,
    bool isShowToast = true,
    bool isShowLoading = false,
    CancelToken? cancelToken,
  }) async {
    try {
      if (isShowLoading) {
        _config.loadingController?.show();
      }
      final response = await _dio.post(
        path,
        data: data,
        cancelToken: cancelToken ?? this.cancelToken,
      );
      // var businessResponse =
      //     _config.responseWrapper<T>(response.data, fromJsonT);
      var businessResponse = _config.responseWrapper2<T>(response.data);
      _config.businessErrorHandler
          ?.call<R>(businessResponse, isShowToast, path);

      return businessResponse;
    } finally {
      if (isShowLoading) {
        _config.loadingController?.dismiss();
      }
    }
  }

  Future<R> get<T, R>(
    String path, {
    T Function(dynamic data)? fromJsonT,
    Map<String, dynamic>? queryParameters,
    bool isShowToast = true,
    bool isShowLoading = false,
    CancelToken? cancelToken,
  }) async {
    try {
      if (isShowLoading) {
        _config.loadingController?.show();
      }
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        cancelToken: cancelToken ?? this.cancelToken,
      );
      // var businessResponse =
      //     _config.responseWrapper<T>(response.data, fromJsonT);
      var businessResponse = _config.responseWrapper2<T>(response.data);
      _config.businessErrorHandler
          ?.call<R>(businessResponse, isShowToast, path);
      return businessResponse;
    } finally {
      if (isShowLoading) {
        _config.loadingController?.dismiss();
      }
    }
  }

  void cancelAllRequests() {
    _cancelToken?.cancel("cancel all requests");
    // TODO 会不会有并发问题
    _cancelToken = null;
  }
}
