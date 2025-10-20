import 'package:flutter/widgets.dart';

/// 图片加载配置类
class ImageLoaderConfig {
  /// 默认占位图路径
  final String? defaultPlaceholder;

  /// 是否启用资源加密
  final bool isRe;

  /// 资源加密后的输出目录
  final String? resEncryptionOutDir;

  /// 默认占位图适配方式
  final BoxFit defaultPlaceholderFit;

  /// 默认网络图片适配方式
  final BoxFit defaultNetworkImageFit;

  /// 默认动画时长
  final Duration fadeOutDuration;
  final Duration placeholderFadeInDuration;
  final Duration fadeInDuration;

  /// 是否在URL改变时使用旧图片
  final bool useOldImageOnUrlChange;

  const ImageLoaderConfig({
    this.defaultPlaceholder,
    this.isRe = false,
    this.resEncryptionOutDir,
    this.defaultPlaceholderFit = BoxFit.cover,
    this.defaultNetworkImageFit = BoxFit.cover,
    this.fadeOutDuration = const Duration(milliseconds: 200),
    this.placeholderFadeInDuration = const Duration(milliseconds: 200),
    this.fadeInDuration = const Duration(milliseconds: 200),
    this.useOldImageOnUrlChange = false,
  });

  /// 创建默认配置
  factory ImageLoaderConfig.defaultConfig() {
    return const ImageLoaderConfig();
  }

  /// 创建自定义配置
  factory ImageLoaderConfig.custom({
    String? defaultPlaceholder,
    bool isRe = false,
    String? resEncryptionOutDir,
    BoxFit defaultPlaceholderFit = BoxFit.cover,
    BoxFit defaultNetworkImageFit = BoxFit.cover,
    Duration? fadeOutDuration,
    Duration? placeholderFadeInDuration,
    Duration? fadeInDuration,
    bool useOldImageOnUrlChange = false,
  }) {
    return ImageLoaderConfig(
      defaultPlaceholder: defaultPlaceholder,
      isRe: isRe,
      resEncryptionOutDir: resEncryptionOutDir,
      defaultPlaceholderFit: defaultPlaceholderFit,
      defaultNetworkImageFit: defaultNetworkImageFit,
      fadeOutDuration: fadeOutDuration ?? const Duration(milliseconds: 10),
      placeholderFadeInDuration:
          placeholderFadeInDuration ?? const Duration(milliseconds: 10),
      fadeInDuration: fadeInDuration ?? const Duration(milliseconds: 10),
      useOldImageOnUrlChange: useOldImageOnUrlChange,
    );
  }
}
