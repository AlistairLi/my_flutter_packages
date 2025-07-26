import 'package:dio/dio.dart';

class ErrorInterceptor extends Interceptor {
  final void Function(Object error, StackTrace stack)? onException;

  ErrorInterceptor(this.onException);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (onException != null) {
      onException!(err, err.stackTrace);
    }
    Response response = Response(
      requestOptions: err.requestOptions,
      data: null,
    );
    handler.resolve(response);
  }
}
