/// 封装业务层 API 响应数据结构
class ApiResponse<T> {
  final int code;
  final String message;
  final T? data;

  ApiResponse({
    required this.code,
    required this.message,
    required this.data,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic data) fromJsonT,
  ) {
    var data = json['data'];
    return ApiResponse(
      code: json['code'] ?? -1,
      message: json['msg'] ?? "",
      data: (data != null && data != "") ? fromJsonT(data) : null,
    );
  }

  bool get isSuccess => code == 0;
}

/// 在 ApiResponse<T> 加上扩展方法
extension ApiResponseX<T> on ApiResponse<T> {
  bool get isTokenExpired => code == 1003;

  bool get isUpgradeRequired => code == 1001;
}
