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

/// 示例代码，需要调用方来实现
/// 默认网络客户端实现（使用dio）
class DefaultNetworkClient implements NetworkClient {
  final Duration timeout;
  final Map<String, String> defaultHeaders;

  DefaultNetworkClient({
    this.timeout = const Duration(seconds: 30),
    this.defaultHeaders = const {},
  });

  @override
  Future<Map<String, dynamic>> get(
    String url, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    // 这里需要导入dio包
    // 为了保持库的灵活性，这里只是接口定义
    // 实际实现由调用方提供
    throw UnimplementedError('请实现具体的网络请求逻辑');
  }

  @override
  Future<Map<String, dynamic>> post(
    String url, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    throw UnimplementedError('请实现具体的网络请求逻辑');
  }
}
