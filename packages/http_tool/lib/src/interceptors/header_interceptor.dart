import 'package:dio/dio.dart';

class HeaderInterceptor extends Interceptor {
  final Map<String, dynamic> Function()? headersBuilder;

  HeaderInterceptor(this.headersBuilder);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final headers = headersBuilder?.call();
    if (headers != null) {
      options.headers.addAll(headers);
    }
    handler.next(options);
  }
}
