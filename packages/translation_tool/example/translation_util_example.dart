import 'package:translation_tool/translation_tool.dart';

/// Example of Application Layer Translation Tools
class TranslationUtilExample {
  TranslationUtilExample._();

  /// Initialize translation tool
  /// The timing of the call:
  ///   - Called when the app starts
  static Future<void> initialize() async {
    // Initialize cache implementation and network implementation
    var compositeCacheManager = EnhancedCompositeCacheManager(
      localCache: LocalCacheManager(), // Local Cache Implementation
    );
    compositeCacheManager.initialize();
    TranslationHelper.initialize(
      cacheManager: compositeCacheManager,
      networkClient: DFNetworkClient(),
    );
  }

  /// Set translation tool parameters
  /// The timing of the call:
  /// - When entering the home page
  /// - When switching the app language
  static void setupTranslation(String appLanguageCode) {
    TranslationHelper.setGlobalConfig(TranslationRequestConfig(
      apiKey: "your_api_key_here",
      targetLanguage: appLanguageCode,
    ));
  }

  /// Translated text
  /// Use the target language code set globally
  static Future<String?> translateText(String text) async {
    try {
      return await TranslationHelper.translate(text);
    } catch (e) {
      print('translation failure: $e');
      return null;
    }
  }

  /// Please provide the text to be translated and the target language code.
  static Future<String?> translateToLanguage(
    String text,
    String targetLanguage,
  ) async {
    final config = TranslationRequestConfig(targetLanguage: targetLanguage);
    try {
      return await TranslationHelper.translateWithConfig(text, config);
    } catch (e) {
      print('translation failure: $e');
      return null;
    }
  }

  /// Obtain cache translation
  static Future<String?> getCache(String text, [String? targetLanguage]) async {
    return await TranslationHelper.getCache(text, targetLanguage);
  }

  /// Retrieve the cache from the memory cache.
  static String? getCacheSync(String text, [String? targetLanguage]) {
    return TranslationHelper.getCacheSync(text, targetLanguage);
  }
}

/// Local caching implementation
class LocalCacheManager implements CacheManager {
  @override
  Future<String?> get(String key) async {
    // var map = HiveUtil.getAppObject(DFHiveKeys.translationCache);
    // return map[key];
    return "";
  }

  @override
  String? getSync(String key) {
    return "";
  }

  @override
  Future<void> set(String key, String value) async {
    // var map = HiveUtil.getAppObject(DFHiveKeys.translationCache);
    // map[key] = value;
    // await HiveUtil.putAppObject(DFHiveKeys.translationCache, map);
  }

  @override
  Future<bool> contains(String key) async {
    // var map = HiveUtil.getAppObject(DFHiveKeys.translationCache);
    // return map.containsKey(key);
    return false;
  }

  @override
  Future<void> clear() async {
    // await HiveUtil.putAppObject(DFHiveKeys.translationCache, {});
  }

  @override
  Future<void> delete(String key) async {
    // var map = HiveUtil.getAppObject(DFHiveKeys.translationCache);
    // map.remove(key);
    // await HiveUtil.putAppObject(DFHiveKeys.translationCache, map);
  }

  @override
  Future<Map<String, String>> getAllEntries() async {
    // return HiveUtil.getAppObject(DFHiveKeys.translationCache)
    //     as Map<String, String>;
    return {};
  }

  @override
  Future<void> setAll(Map<String, String> entries) async {
    // await HiveUtil.putAppObject(DFHiveKeys.translationCache, entries);
  }
}

class DFNetworkClient implements NetworkClient {
  @override
  Future<Map<String, dynamic>> get(
    String url, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    // Dio dio = Dio(BaseOptions(
    //   sendTimeout: Duration(seconds: 20),
    //   receiveTimeout: Duration(seconds: 20),
    //   connectTimeout: Duration(seconds: 20),
    // ));
    // var response = await dio.get(url, queryParameters: queryParameters);
    // return response.data;
    return {};
  }

  @override
  Future<Map<String, dynamic>> post(
    String url, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    throw UnimplementedError();
  }
}
