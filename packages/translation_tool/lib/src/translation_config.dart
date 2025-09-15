/// 翻译配置类
class TranslationConfig {
  /// 默认内存缓存容量
  static const int defaultCapacity = 500;

  /// 数据批量保存到本地的默认间隔时间, 默认15秒
  static const int defaultSaveInterval = 15 * 1000;

  /// 触发数据批量保存到本地的默认消息条数，默认10条
  static const int defaultBatchSaveCount = 10;

  /// 全局Google翻译API密钥
  static String? _globalApiKey;

  /// 全局目标语言代码
  static String? _globalTargetLanguage;

  /// 设置全局API密钥
  static void setGlobalApiKey(String apiKey) {
    _globalApiKey = apiKey;
  }

  /// 获取全局API密钥
  static String? get globalApiKey => _globalApiKey;

  /// 设置全局目标语言
  static void setGlobalTargetLanguage(String languageCode) {
    _globalTargetLanguage = languageCode;
  }

  /// 获取全局目标语言
  static String? get globalTargetLanguage => _globalTargetLanguage;

  /// 清除全局配置
  static void clearGlobalConfig() {
    _globalApiKey = null;
    _globalTargetLanguage = null;
  }
}

/// 翻译请求配置
class TranslationRequestConfig {
  final String? apiKey;
  final String? targetLanguage;
  final String? sourceLanguage;
  final String format;

  const TranslationRequestConfig({
    this.apiKey,
    this.targetLanguage,
    this.sourceLanguage,
    this.format = 'text',
  });

  /// 获取有效的API密钥（优先使用请求配置，其次使用全局配置）
  String? get effectiveApiKey => apiKey ?? TranslationConfig.globalApiKey;

  /// 获取有效的目标语言（优先使用请求配置，其次使用全局配置）
  String? get effectiveTargetLanguage =>
      targetLanguage ?? TranslationConfig.globalTargetLanguage;

  /// 创建配置的副本并更新指定字段
  TranslationRequestConfig copyWith({
    String? apiKey,
    String? targetLanguage,
    String? sourceLanguage,
    String? format,
  }) {
    return TranslationRequestConfig(
      apiKey: apiKey ?? this.apiKey,
      targetLanguage: targetLanguage ?? this.targetLanguage,
      sourceLanguage: sourceLanguage ?? this.sourceLanguage,
      format: format ?? this.format,
    );
  }
}
