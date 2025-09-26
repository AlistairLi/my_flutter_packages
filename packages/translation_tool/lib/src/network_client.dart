/// 网络客户端接口
abstract class NetworkClient {
  /// 执行GET请求
  Future<Map<String, dynamic>> get(
    String url, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  });

  /// 执行POST请求
  Future<Map<String, dynamic>> post(
    String url, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  });
}
