import 'package:translation_tool/translation_tool.dart';

/// 自定义本地缓存管理器示例
class CustomLocalCacheManager implements CacheManager {
  final Map<String, String> _storage = {};

  @override
  Future<String?> get(String key) async {
    return _storage[key];
  }

  @override
  String? getSync(String key) {
    return _storage[key];
  }

  @override
  Future<void> set(String key, String value) async {
    _storage[key] = value;
    print('本地缓存已保存: $key -> $value');
  }

  @override
  Future<bool> contains(String key) async {
    return _storage.containsKey(key);
  }

  @override
  Future<void> delete(String key) async {
    _storage.remove(key);
  }

  @override
  Future<void> clear() async {
    _storage.clear();
  }

  @override
  Future<Map<String, String>> getAllEntries() async {
    return Map.from(_storage);
  }

  @override
  Future<void> setAll(Map<String, String> entries) async {
    _storage.addAll(entries);
    print('批量保存 ${entries.length} 条数据到本地缓存');
  }
}

/// 自定义网络客户端示例（使用dio）
class CustomNetworkClient implements NetworkClient {
  @override
  Future<Map<String, dynamic>> get(
    String url, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    // 这里应该使用dio或其他HTTP客户端
    // 为了演示，这里返回模拟数据
    print('发送网络请求: $url');
    print('查询参数: $queryParameters');

    // 模拟网络延迟
    await Future.delayed(Duration(milliseconds: 500));

    // 返回模拟的Google翻译响应
    return {
      'data': {
        'translations': [
          {
            'translatedText': 'Hello World (translated)',
            'detectedSourceLanguage': 'zh',
          }
        ]
      }
    };
  }

  @override
  Future<Map<String, dynamic>> post(
    String url, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    throw UnimplementedError('POST请求未实现');
  }
}

void main() async {
  // 1. 设置全局配置
  TranslationHelper.setGlobalApiKey('your_google_translate_api_key');
  TranslationHelper.setGlobalTargetLanguage('en');

  // 2. 初始化翻译服务
  TranslationHelper.initialize(
    cacheManager: EnhancedCompositeCacheManager(
      localCache: CustomLocalCacheManager(),
      saveIntervalMs: 5000, // 5秒保存间隔
      saveThreshold: 3, // 3条消息触发保存
    ),
    networkClient: CustomNetworkClient(),
  );

  // 3. 使用全局配置翻译
  print('=== 使用全局配置翻译 ===');
  final result1 = await TranslationHelper.translate('你好世界');
  print('翻译结果: $result1');

  // 4. 使用自定义配置翻译
  print('\n=== 使用自定义配置翻译 ===');
  final customConfig = TranslationRequestConfig(
    targetLanguage: 'ja', // 翻译为日语
    sourceLanguage: 'zh', // 源语言为中文
  );

  final result2 = await TranslationHelper.translateWithConfig(
    '你好世界',
    customConfig,
  );
  print('翻译结果: $result2');

  // 5. 批量翻译
  print('\n=== 批量翻译 ===');
  final texts = ['你好', '世界', '翻译'];
  final results = await TranslationHelper.translateBatch(texts);
  print('批量翻译结果: $results');

  // 6. 检查缓存
  print('\n=== 缓存管理 ===');
  final hasCached = await TranslationHelper.hasCache('你好世界', 'en');
  print('是否有缓存: $hasCached');

  final stats = TranslationHelper.getCacheStats();
  print('缓存统计: $stats');

  // 7. 演示增强缓存管理器的条件保存功能
  print('\n=== 增强缓存管理器功能演示 ===');

  // 创建增强缓存管理器
  final enhancedCache = EnhancedCompositeCacheManager(
    localCache: CustomLocalCacheManager(),
    saveIntervalMs: 3000, // 3秒保存间隔
    saveThreshold: 2, // 2条消息触发保存
  );

  // 初始化（会从本地加载数据）
  await enhancedCache.initialize();

  // 添加一些数据，观察条件保存
  print('添加数据1...');
  await enhancedCache.set('test_key_1', 'test_value_1');

  print('添加数据2...');
  await enhancedCache.set('test_key_2', 'test_value_2');

  // 等待一段时间，观察时间间隔触发保存
  print('等待4秒观察时间间隔触发保存...');
  await Future.delayed(Duration(seconds: 4));

  await enhancedCache.set('test_key_3', 'test_value_3');

  final enhancedStats = enhancedCache.getStats();
  print('增强缓存统计: $enhancedStats');

  // 7. 使用构建器模式创建服务
  print('\n=== 使用构建器模式 ===');
  final service = TranslationServiceBuilder()
      .cacheManager(MemoryCacheManager(capacity: 100))
      .networkClient(CustomNetworkClient())
      .build();

  final result3 = await service.translate('测试文本');
  print('构建器创建的服务翻译结果: $result3');
}
