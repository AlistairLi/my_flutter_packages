/// 封装业务层 API 响应数据结构
class ApiResponseExample<T> {
  final int code;
  final String message;
  final T? data;

  ApiResponseExample({
    required this.code,
    required this.message,
    required this.data,
  });

  factory ApiResponseExample.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic data) fromJsonT,
  ) {
    var data = json['data'];
    return ApiResponseExample(
      code: json['code'] ?? -1,
      message: json['msg'] ?? "",
      data: (data != null && data != "") ? fromJsonT(data) : null,
    );
  }

  bool get isSuccess => code == 0;
}

/// 在 ApiResponseExample<T> 加上扩展方法
extension ApiResponseX<T> on ApiResponseExample<T> {
  bool get isTokenExpired => code == 11000;
}
