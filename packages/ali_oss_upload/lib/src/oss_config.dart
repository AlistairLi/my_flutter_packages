/// OSS上传配置
class OssUploadConfig {
  /// 连接超时时间
  final Duration connectTimeout;

  /// 发送超时时间
  final Duration sendTimeout;

  /// 接收超时时间
  final Duration receiveTimeout;

  /// 最大重试次数
  final int maxRetries;

  /// 重试间隔
  final Duration retryInterval;

  const OssUploadConfig({
    this.connectTimeout = const Duration(seconds: 30),
    this.sendTimeout = const Duration(seconds: 30),
    this.receiveTimeout = const Duration(seconds: 30),
    this.maxRetries = 3,
    this.retryInterval = const Duration(seconds: 1),
  });
}
