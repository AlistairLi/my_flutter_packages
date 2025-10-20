import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:http_tool/src/core/network_config.dart';
import 'package:http_tool/src/interceptors/header_interceptor.dart';

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
      contentType: _config.contentType,
      responseType: _config.responseType,
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

    _dio.interceptors.add(RetryInterceptor(
      dio: _dio,
      retries: _config.retries,
      retryDelays: _config.retryDelays,
    ));
    // _dio.interceptors.add(ErrorInterceptor(_config.onDioException));
  }

  void addInterceptor(Interceptor interceptor) {
    _dio.interceptors.add(interceptor);
  }

  /// 将拦截器添加到最前面
  void addInterceptorAtFirst(Interceptor interceptor) {
    _dio.interceptors.insert(0, interceptor);
  }

  Future<R?> post<T, R>(
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
    } on DioException catch (e) {
      _config.onDioException?.call(e, e.stackTrace, isShowToast);
    } catch (e) {
      _config.onException?.call(e, _dio.options, path, isShowToast);
    } finally {
      if (isShowLoading) {
        _config.loadingController?.dismiss();
      }
    }
    return null;
  }

  Future<R?> get<T, R>(
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
    } on DioException catch (e) {
      _config.onDioException?.call(e, e.stackTrace, isShowToast);
    } catch (e) {
      _config.onException?.call(e, _dio.options, path, isShowToast);
    } finally {
      if (isShowLoading) {
        _config.loadingController?.dismiss();
      }
    }
    return null;
  }

  void cancelAllRequests() {
    _cancelToken?.cancel("cancel all requests");
    // TODO 会不会有并发问题
    _cancelToken = null;
  }
}
