import 'cache_manager.dart';
import 'network_client.dart';
import 'translation_config.dart';
import 'translation_service.dart';

/// 便捷的翻译工具类
class TranslationHelper {
  static TranslationService? _instance;
  static CacheManager? _defaultCacheManager;
  static NetworkClient? _defaultNetworkClient;

  /// 初始化翻译服务
  static void initialize({
    CacheManager? cacheManager,
    NetworkClient? networkClient,
  }) {
    _defaultCacheManager = cacheManager;
    _defaultNetworkClient = networkClient;
  }

  /// 获取翻译服务实例
  static TranslationService get _service {
    if (_instance == null) {
      if (_defaultCacheManager == null || _defaultNetworkClient == null) {
        throw StateError(
            'Please call TranslationHelper.initialize() to initialize the service first.');
      }

      _instance = TranslationService(
        cacheManager: _defaultCacheManager!,
        networkClient: _defaultNetworkClient!,
      );
    }
    return _instance!;
  }

  static void setGlobalConfig(TranslationRequestConfig config) {
    TranslationConfig.setGlobalConfig = config;
  }

  /// 翻译文本（使用全局配置）
  static Future<String?> translate(String text) async {
    return await _service.translate(text);
  }

  /// 翻译文本（使用自定义配置）
  static Future<String?> translateWithConfig(
    String text,
    TranslationRequestConfig config,
  ) async {
    return await _service.translate(text, config: config);
  }

  /// 批量翻译
  static Future<List<String?>> translateBatch(List<String> texts) async {
    return await _service.translateBatch(texts);
  }

  /// 批量翻译（使用自定义配置）
  static Future<List<String?>> translateBatchWithConfig(
    List<String> texts,
    TranslationRequestConfig config,
  ) async {
    return await _service.translateBatch(texts, config: config);
  }

  /// 清除缓存
  static Future<void> clearCache() async {
    await _service.clearCache();
  }

  /// 删除特定缓存
  static Future<void> deleteCache(String text, [String? targetLanguage]) async {
    await _service.deleteCache(text, targetLanguage);
  }

  /// 检查是否有缓存
  static Future<bool> hasCache(String text, [String? targetLanguage]) async {
    return await _service.hasCache(text, targetLanguage);
  }

  /// 获取缓存翻译
  static Future<String?> getCache(String text, [String? targetLanguage]) async {
    return await _service.getCache(text, targetLanguage);
  }

  /// 同步获取缓存翻译
  static String? getCacheSync(String text, [String? targetLanguage]) {
    return _service.getCacheSync(text, targetLanguage);
  }

  /// 获取缓存统计信息
  static Map<String, dynamic> getCacheStats() {
    return _service.getCacheStats();
  }

  /// 重置服务实例（用于测试或重新配置）
  static void reset() {
    _instance = null;
  }
}
