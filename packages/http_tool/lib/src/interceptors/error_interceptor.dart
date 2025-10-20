// import 'package:dio/dio.dart';
//
// class ErrorInterceptor extends Interceptor {
//   final void Function(DioException error, StackTrace stack)? onException;
//
//   ErrorInterceptor(this.onException);
//
//   @override
//   void onError(DioException err, ErrorInterceptorHandler handler) {
//     if (onException != null) {
//       onException!(err, err.stackTrace);
//     }
//     super.onError(err, handler);
//   }
// }
