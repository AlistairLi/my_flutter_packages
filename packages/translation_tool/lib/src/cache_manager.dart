import 'package:translation_tool/src/log.dart';
import 'package:translation_tool/src/translation_config.dart';

import 'lru_cache.dart';

/// 缓存管理器接口
abstract class CacheManager {
  /// 获取缓存值
  Future<String?> get(String key);

  /// 获取缓存值（同步）
  String? getSync(String key);

  /// 设置缓存值
  Future<void> set(String key, String value);

  /// 检查是否包含缓存
  Future<bool> contains(String key);

  /// 删除缓存
  Future<void> delete(String key);

  /// 清空所有缓存
  Future<void> clear();

  /// 获取所有键值对（用于批量操作）
  Future<Map<String, String>> getAllEntries();

  /// 批量设置键值对
  Future<void> setAll(Map<String, String> entries);
}

/// 内存缓存管理器
class MemoryCacheManager implements CacheManager {
  final LruCache<String, String> _cache;

  MemoryCacheManager({
    int capacity = TranslationConfig.defaultCapacity,
  }) : _cache = LruCache(capacity);

  @override
  Future<String?> get(String key) async {
    return _cache.get(key);
  }

  @override
  String? getSync(String key) {
    return _cache.get(key);
  }

  @override
  Future<void> set(String key, String value) async {
    _cache.set(key, value);
  }

  @override
  Future<bool> contains(String key) async {
    return _cache.containsKey(key);
  }

  @override
  Future<void> delete(String key) async {
    _cache.delete(key);
  }

  @override
  Future<void> clear() async {
    _cache.clear();
  }

  @override
  Future<Map<String, String>> getAllEntries() async {
    return Map.fromEntries(_cache.entries);
  }

  @override
  Future<void> setAll(Map<String, String> entries) async {
    for (final entry in entries.entries) {
      _cache.set(entry.key, entry.value);
    }
  }

  /// 缓存是否已满
  bool get isFull => _cache.isFull;

  /// 当前缓存中的条目数量
  int get length => _cache.length;

  /// 获取缓存统计信息
  Map<String, dynamic> getStats() {
    return {
      'capacity': _cache.capacity,
      'size': _cache.length,
      'usage': _cache.length / _cache.capacity,
      'isEmpty': _cache.isEmpty,
      'isFull': _cache.isFull,
    };
  }
}

/// 复合缓存管理器（内存 + 本地）
class CompositeCacheManager implements CacheManager {
  final CacheManager _memoryCache;
  final CacheManager _localCache;

  CompositeCacheManager({
    CacheManager? memoryCache,
    required CacheManager localCache,
  })  : _memoryCache = memoryCache ?? MemoryCacheManager(),
        _localCache = localCache;

  @override
  Future<String?> get(String key) async {
    // 先从内存缓存获取
    final memoryValue = await _memoryCache.get(key);
    if (memoryValue != null) {
      return memoryValue;
    }

    // 内存缓存没有，从本地缓存获取
    final localValue = await _localCache.get(key);
    if (localValue != null) {
      // 将本地缓存的值也放入内存缓存
      await _memoryCache.set(key, localValue);
      return localValue;
    }

    return null;
  }

  @override
  String? getSync(String key) {
    return _memoryCache.getSync(key);
  }

  @override
  Future<void> set(String key, String value) async {
    // 同时设置内存缓存和本地缓存
    await Future.wait([
      _memoryCache.set(key, value),
      _localCache.set(key, value),
    ]);
  }

  @override
  Future<bool> contains(String key) async {
    // 检查内存缓存
    if (await _memoryCache.contains(key)) {
      return true;
    }

    // 检查本地缓存
    return await _localCache.contains(key);
  }

  @override
  Future<void> delete(String key) async {
    // 同时删除内存缓存和本地缓存
    await Future.wait([
      _memoryCache.delete(key),
      _localCache.delete(key),
    ]);
  }

  @override
  Future<void> clear() async {
    // 同时清空内存缓存和本地缓存
    await Future.wait([
      _memoryCache.clear(),
      _localCache.clear(),
    ]);
  }

  @override
  Future<Map<String, String>> getAllEntries() async {
    // 先从内存缓存获取
    var memoryAllEntries = await _memoryCache.getAllEntries();
    if (memoryAllEntries.isNotEmpty) {
      return memoryAllEntries;
    }

    // 内存缓存没有，从本地缓存获取
    var localAllEntries = await _localCache.getAllEntries();
    if (localAllEntries.isNotEmpty) {
      // 将本地缓存的值也放入内存缓存
      await _memoryCache.setAll(localAllEntries);
      return localAllEntries;
    }

    return {};
  }

  @override
  Future<void> setAll(Map<String, String> entries) async {
    // 同时设置到内存缓存和本地缓存
    await Future.wait([
      _memoryCache.setAll(entries),
      _localCache.setAll(entries),
    ]);
  }
}

/// 增强的复合缓存管理器（支持本地存储加载和条件保存）
class EnhancedCompositeCacheManager implements CacheManager {
  final String tag = 'EnhancedCompositeCacheManager';
  final CacheManager _memoryCache;
  final CacheManager _localCache;

  /// 数据保存时间间隔（毫秒）
  final int _saveIntervalMs;

  /// 触发数据保存的消息条数
  final int _saveThreshold;

  /// 最近保存时间戳
  int _lastSaveTime = 0;

  /// 是否已初始化
  bool _isInitialized = false;

  EnhancedCompositeCacheManager({
    CacheManager? memoryCache,
    required CacheManager localCache,
    int saveIntervalMs = TranslationConfig.defaultSaveInterval,
    int saveThreshold = TranslationConfig.defaultBatchSaveCount,
  })  : _memoryCache = memoryCache ?? MemoryCacheManager(),
        _localCache = localCache,
        _saveIntervalMs = saveIntervalMs,
        _saveThreshold = saveThreshold;

  /// 初始化时从本地存储加载所有数据到内存缓存
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final localEntries = await _localCache.getAllEntries();

      if (localEntries.isNotEmpty) {
        await _memoryCache.setAll(localEntries);
      }

      _isInitialized = true;
      _lastSaveTime = DateTime.now().millisecondsSinceEpoch;
    } catch (e) {
      transLog(tag, 'Failed to load local cache: $e');
      _isInitialized = true; // 即使失败也标记为已初始化
    }
  }

  @override
  Future<String?> get(String key) async {
    // 确保已初始化
    if (!_isInitialized) {
      await initialize();
    }

    // 先从内存缓存获取
    final memoryValue = await _memoryCache.get(key);
    if (memoryValue != null) {
      return memoryValue;
    }

    // 内存缓存没有，从本地缓存获取
    final localValue = await _localCache.get(key);
    if (localValue != null) {
      // 将本地缓存的值也放入内存缓存
      await _memoryCache.set(key, localValue);
      return localValue;
    }

    return null;
  }

  @override
  String? getSync(String key) {
    return _memoryCache.getSync(key);
  }

  @override
  Future<void> set(String key, String value) async {
    // 确保已初始化
    if (!_isInitialized) {
      await initialize();
    }

    // 设置到内存缓存
    await _memoryCache.set(key, value);

    // 批量保存到本地缓存
    await _saveAllToLocal();
  }

  @override
  Future<bool> contains(String key) async {
    // 确保已初始化
    if (!_isInitialized) {
      await initialize();
    }

    // 检查内存缓存
    if (await _memoryCache.contains(key)) {
      return true;
    }

    // 检查本地缓存
    return await _localCache.contains(key);
  }

  @override
  Future<void> delete(String key) async {
    // 确保已初始化
    if (!_isInitialized) {
      await initialize();
    }

    // 同时删除内存缓存和本地缓存
    await Future.wait([
      _memoryCache.delete(key),
      _localCache.delete(key),
    ]);
  }

  @override
  Future<void> clear() async {
    // 确保已初始化
    if (!_isInitialized) {
      await initialize();
    }

    // 同时清空内存缓存和本地缓存
    await Future.wait([
      _memoryCache.clear(),
      _localCache.clear(),
    ]);

    _lastSaveTime = DateTime.now().millisecondsSinceEpoch;
  }

  @override
  Future<Map<String, String>> getAllEntries() async {
    // 确保已初始化
    if (!_isInitialized) {
      await initialize();
    }

    // 优先返回内存缓存的条目
    return await _memoryCache.getAllEntries();
  }

  @override
  Future<void> setAll(Map<String, String> entries) async {
    // 确保已初始化
    if (!_isInitialized) {
      await initialize();
    }

    // 设置到内存缓存
    await _memoryCache.setAll(entries);

    // 检查是否需要保存到本地存储
    await _saveAllToLocal();
  }

  /// 检查保存到本地存储的条件
  /// 1. 数据保存时间间隔
  /// 1. 设定触发数据保存的消息条数
  /// 2. 翻译文本容器填满之后，消息条数不再作为触发数据保存的条件
  bool _checkSaveConditions(bool force) {
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    final timeElapsed = currentTime - _lastSaveTime;

    // 获取内存缓存信息
    int length = 0;
    bool isFull = false;
    var memoryCache = _memoryCache;
    if (memoryCache is MemoryCacheManager) {
      isFull = memoryCache.isFull;
      length = memoryCache.length;
    }

    // 判断是否需要保存的条件：
    // 1.强制保存
    // 2.时间间隔到达
    // 3.达到保存阈值 & 内存缓存未满
    bool shouldSave = force ||
        timeElapsed >= _saveIntervalMs ||
        (length % _saveThreshold == 0 && !isFull);
    return shouldSave;
  }

  /// 将所有内存缓存数据保存到本地存储, 需要检查保存条件
  Future<void> _saveAllToLocal() async {
    try {
      if (!_checkSaveConditions(false)) {
        return;
      }
      final memoryEntries = await _memoryCache.getAllEntries();
      await _localCache.setAll(memoryEntries);
      // 更新状态
      _lastSaveTime = DateTime.now().millisecondsSinceEpoch;
    } catch (e) {
      transLog(tag, 'Failed to save to local storage: $e');
    }
  }

  /// 获取内存缓存统计信息
  Map<String, dynamic> _getMemoryCacheStats() {
    var memoryCache = _memoryCache;
    if (memoryCache is MemoryCacheManager) {
      return memoryCache.getStats();
    }
    return {'isFull': false};
  }

  /// 获取缓存统计信息
  Map<String, dynamic> getStats() {
    final memoryStats = _getMemoryCacheStats();
    return {
      ...memoryStats,
      'lastSaveTime': _lastSaveTime,
      'saveIntervalMs': _saveIntervalMs,
      'saveThreshold': _saveThreshold,
      'isInitialized': _isInitialized,
    };
  }
}

/// 缓存键生成器
class CacheKeyGenerator {
  /// 生成翻译缓存键（包含目标语言）
  static String generateTranslationKey(String text, String targetLanguage) {
    return '${targetLanguage}_${_generateMd5(text)}';
  }

  /// 生成MD5哈希
  static String _generateMd5(String text) {
    // 这里可以使用crypto包生成MD5，为了简化，这里使用简单的哈希算法
    int hash = 0;
    for (int i = 0; i < text.length; i++) {
      hash = ((hash << 5) - hash + text.codeUnitAt(i)) & 0xffffffff;
    }
    return hash.toRadixString(16); // eg: en_cc969a84
  }
}
