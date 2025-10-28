import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// 文件本地缓存管理
class FileCacheManager {
  static const key = 'smart_video_player_file_cache';
  static CacheManager instance = CacheManager(
    Config(
      key,
      stalePeriod: const Duration(days: 10),
      maxNrOfCacheObjects: 30,
      repo: JsonCacheInfoRepository(databaseName: key),
      fileSystem: IOFileSystem(key),
      fileService: HttpFileService(),
    ),
  );

  /// 获取缓存文件
  Future<FileInfo?> getFileFromCache(String url,
      {bool ignoreMemCache = false}) async {
    return await instance.getFileFromCache(url, ignoreMemCache: ignoreMemCache);
  }

  /// 下载文件
  Future<FileInfo> downloadFile(String url,
      {String? key,
      Map<String, String>? authHeaders,
      bool force = false}) async {
    return instance.downloadFile(url,
        key: key, authHeaders: authHeaders, force: force);
  }
}
