/// 翻译配置类
class TranslationConfig {
  /// 默认内存缓存容量
  static const int defaultCapacity = 500;

  /// 数据批量保存到本地的默认间隔时间, 默认15秒
  static const int defaultSaveInterval = 15 * 1000;

  /// 触发数据批量保存到本地的默认消息条数，默认10条
  static const int defaultBatchSaveCount = 10;

  static TranslationRequestConfig? _globalConfig;

  static set setGlobalConfig(TranslationRequestConfig config) =>
      _globalConfig = config;

  static TranslationRequestConfig? get globalConfig => _globalConfig;
}

/// 翻译请求配置
class TranslationRequestConfig {
  final String? translationApi;
  final String? apiKey;
  final String? targetLanguage;
  final String format;

  const TranslationRequestConfig({
    this.translationApi,
    this.apiKey,
    this.targetLanguage,
    this.format = 'text',
  });

  /// 创建配置的副本并更新指定字段
  TranslationRequestConfig copyWith({
    String? translationApi,
    String? apiKey,
    String? targetLanguage,
    String? sourceLanguage,
    String? format,
  }) {
    return TranslationRequestConfig(
      translationApi: translationApi ?? this.translationApi,
      apiKey: apiKey ?? this.apiKey,
      targetLanguage: targetLanguage ?? this.targetLanguage,
      format: format ?? this.format,
    );
  }
}
