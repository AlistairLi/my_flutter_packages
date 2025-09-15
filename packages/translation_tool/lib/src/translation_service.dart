import 'package:translation_tool/src/go_translation_result_model.dart';

import 'cache_manager.dart';
import 'network_client.dart';
import 'translation_config.dart';

/// 翻译服务类
class TranslationService {
  final CacheManager _cacheManager;
  final NetworkClient _networkClient;

  static const String _googleTranslateApi =
      'https://translation.googleapis.com/language/translate/v2';

  TranslationService({
    required CacheManager cacheManager,
    required NetworkClient networkClient,
  })  : _cacheManager = cacheManager,
        _networkClient = networkClient;

  /// 翻译文本
  Future<String?> translate(
    String text, {
    TranslationRequestConfig? config,
  }) async {
    if (text.isEmpty) {
      return null;
    }

    final requestConfig = config ?? const TranslationRequestConfig();

    // 验证配置
    if (requestConfig.effectiveApiKey == null) {
      throw ArgumentError(
          'The API key has not been configured. Please set the global API key or specify it in the request.');
    }

    if (requestConfig.effectiveTargetLanguage == null) {
      throw ArgumentError(
          'The target language has not been configured. Please set the global target language or specify it in the request.');
    }

    // 生成缓存键（包含目标语言）
    final cacheKey = CacheKeyGenerator.generateTranslationKey(
      text,
      requestConfig.effectiveTargetLanguage!,
    );

    // 尝试从缓存获取
    final cachedResult = await _cacheManager.get(cacheKey);
    if (cachedResult != null) {
      return cachedResult;
    }

    // 缓存中没有，执行网络请求
    final translatedText = await _performTranslation(text, requestConfig);

    // 将结果存入缓存
    if (translatedText != null) {
      await _cacheManager.set(cacheKey, translatedText);
    }

    return translatedText;
  }

  /// 执行翻译请求
  Future<String?> _performTranslation(
    String text,
    TranslationRequestConfig config,
  ) async {
    try {
      final queryParameters = <String, dynamic>{
        'key': config.effectiveApiKey,
        'target': config.effectiveTargetLanguage,
        'q': text,
        'format': config.format,
      };

      if (config.sourceLanguage != null) {
        queryParameters['source'] = config.sourceLanguage;
      }

      final response = await _networkClient.get(
        _googleTranslateApi,
        queryParameters: queryParameters,
      );

      return _parseTranslationResponse(response);
    } catch (e) {
      print('[TranslationService]  Translation request failed: $e');
      return null;
    }
  }

  /// 解析翻译响应
  String? _parseTranslationResponse(Map<String, dynamic> response) {
    try {
      String result = "";
      var data = GoTranslationResultModel.fromJson(response);
      data.data?.translations?.forEach((element) {
        result += element.translatedText ?? "";
      });

      return result;
    } catch (e) {
      print(
          '[TranslationService]  Analysis of the translation result failed: $e');
      return null;
    }
  }

  /// 批量翻译
  Future<List<String?>> translateBatch(
    List<String> texts, {
    TranslationRequestConfig? config,
  }) async {
    final results = <String?>[];

    for (final text in texts) {
      final result = await translate(text, config: config);
      results.add(result);
    }

    return results;
  }

  /// 清除翻译缓存
  Future<void> clearCache() async {
    await _cacheManager.clear();
  }

  /// 删除特定文本的缓存
  Future<void> deleteCache(String text, String? targetLanguage) async {
    await _cacheManager.delete(_getCacheKey(text, targetLanguage));
  }

  /// 检查是否有缓存
  Future<bool> hasCache(String text, String? targetLanguage) async {
    return await _cacheManager.contains(_getCacheKey(text, targetLanguage));
  }

  /// 获取缓存翻译
  Future<String?> getCache(String text, String? targetLanguage) async {
    return await _cacheManager.get(_getCacheKey(text, targetLanguage));
  }

  String? getCacheSync(String text, String? targetLanguage) {
    return _cacheManager.getSync(_getCacheKey(text, targetLanguage));
  }

  /// 获取缓存统计信息
  Map<String, dynamic> getCacheStats() {
    if (_cacheManager is MemoryCacheManager) {
      return (_cacheManager as MemoryCacheManager).getStats();
    }
    return {'type': 'custom_cache_manager'};
  }

  /// 获取缓存键
  String _getCacheKey(String text, String? targetLanguage) {
    var language =
        targetLanguage ?? TranslationConfig.globalTargetLanguage ?? "en";
    final cacheKey = CacheKeyGenerator.generateTranslationKey(text, language);
    return cacheKey;
  }
}

/// 翻译服务构建器
class TranslationServiceBuilder {
  CacheManager? _cacheManager;
  NetworkClient? _networkClient;

  TranslationServiceBuilder cacheManager(CacheManager cacheManager) {
    _cacheManager = cacheManager;
    return this;
  }

  TranslationServiceBuilder networkClient(NetworkClient networkClient) {
    _networkClient = networkClient;
    return this;
  }

  TranslationService build() {
    if (_cacheManager == null) {
      throw ArgumentError('The cache manager is necessary.');
    }
    if (_networkClient == null) {
      throw ArgumentError('The network client is necessary.');
    }

    return TranslationService(
      cacheManager: _cacheManager!,
      networkClient: _networkClient!,
    );
  }
}
