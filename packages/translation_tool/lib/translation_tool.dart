/// Google翻译工具库
///
/// 支持内存缓存和本地缓存，可配置的API密钥和目标语言
library;

// 核心服务
export 'src/translation_service.dart';
export 'src/translation_helper.dart';

// 配置
export 'src/translation_config.dart';

// 缓存管理
export 'src/cache_manager.dart';
export 'src/lru_cache.dart';

// 网络客户端
export 'src/network_client.dart';

// 数据模型
export 'src/go_translation_result_model.dart';
