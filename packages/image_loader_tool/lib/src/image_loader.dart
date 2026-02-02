import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_loader_tool/src/image_config.dart';
import 'package:image_loader_tool/src/transparent_image.dart';

/// 图片工具类
class ImageLoader {
  ImageLoader._();

  static Map<String, Uint8List> imgCache = {};

  /// 全局配置
  static ImageLoaderConfig _config = ImageLoaderConfig.defaultConfig();

  /// 设置全局配置
  static void setConfig(ImageLoaderConfig config) {
    _config = config;
  }

  /// 获取当前配置
  static ImageLoaderConfig get config => _config;

  static Uint8List? getUint8List(String name) {
    return imgCache[name];
  }

  /// 获取资源路径
  // static String _getResourcePath(String name) {
  //   if (_config.isRe && _config.resEncryptionOutDir != null) {
  //     return "${_config.resEncryptionOutDir}/$name";
  //   }
  //   return name;
  // }

  /// 创建占位图组件
  static Widget _createPlaceholder(
    String? placeholder,
    double? width,
    double? height,
    BoxFit? fit,
  ) {
    if (placeholder == null || placeholder.isEmpty) {
      return const SizedBox.shrink();
    }
    final shouldUseRe = _config.isRe;
    if (shouldUseRe) {
      return Image.memory(
        imgCache[placeholder] ?? kTransparentImage,
        width: width,
        height: height,
        fit: fit,
      );
    }
    return Image.asset(
      placeholder,
      width: width,
      height: height,
      fit: fit,
    );
  }

  /// 应用圆角裁剪
  /// 优先级：circular > borderRadius > radius > 无圆角
  static Widget _applyBorderRadius(
    Widget child, {
    double? width,
    double? height,
    double? radius,
    BorderRadius? borderRadius,
    bool circular = false,
    BoxBorder? border,
  }) {
    Widget result = child;
    if (circular) {
      result = ClipOval(child: result);
    } else if (borderRadius != null) {
      result = ClipRRect(
        borderRadius: borderRadius,
        child: result,
      );
    } else if (radius != null) {
      result = ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: result,
      );
    }
    if (border != null) {
      result = Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          border: border,
          shape: circular ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: circular
              ? null
              : (borderRadius ??
                  (radius != null ? BorderRadius.circular(radius) : null)),
        ),
        child: result,
      );
    }
    return result;
  }

  ///加载一张网络图片并使用缓存
  ///[imageUrl] 网络图片的地址
  ///[width] 图片视图宽
  ///[height] 图片视图高
  ///[placeholder] 加载占位图，如果为空则使用全局配置的默认占位图
  ///[alignment] 对齐方式，默认 Alignment.center
  ///[fit] 网络图片的裁剪方式
  ///[placeholderFit] 占位图片的裁剪方式
  ///[fadeOutDuration] 淡出动画时长
  ///[placeholderFadeInDuration] 占位图淡入动画时长
  ///[fadeInDuration] 图片淡入动画时长
  ///[useOldImageOnUrlChange] 是否在URL改变时使用旧图片
  ///[circular] 是否设置为圆形
  ///[radius] 圆角半径
  ///[borderRadius] 自定义圆角
  static Widget cachedNetwork(
    String? imageUrl, {
    double? width,
    double? height,
    String? placeholder,
    ImageErrorWidgetBuilder? errorBuilder,
    Alignment alignment = Alignment.center,
    BoxFit? fit = BoxFit.cover,
    BoxFit? placeholderFit = BoxFit.cover,
    Duration? fadeOutDuration,
    Duration? placeholderFadeInDuration,
    Duration? fadeInDuration,
    bool? useOldImageOnUrlChange,
    bool matchTextDirection = false,
    bool circular = false,
    double? radius,
    BorderRadius? borderRadius,
    BoxBorder? border,
  }) {
    // 使用传入参数或全局配置的默认值
    final actualPlaceholder = placeholder ?? _config.defaultPlaceholder;

    // 如果URL为空或null，直接返回占位图，避免网络请求错误
    if (imageUrl == null || imageUrl.trim().isEmpty) {
      final placeholderWidget = _createPlaceholder(
        actualPlaceholder,
        width,
        height,
        placeholderFit,
      );
      return _applyBorderRadius(
        placeholderWidget,
        width: width,
        height: height,
        radius: radius,
        borderRadius: borderRadius,
        circular: circular,
        border: border,
      );
    }

    final actualFadeOutDuration = fadeOutDuration ?? _config.fadeOutDuration;
    final actualPlaceholderFadeInDuration =
        placeholderFadeInDuration ?? _config.placeholderFadeInDuration;
    final actualFadeInDuration = fadeInDuration ?? _config.fadeInDuration;
    final actualUseOldImageOnUrlChange =
        useOldImageOnUrlChange ?? _config.useOldImageOnUrlChange;

    final imageWidget = CachedNetworkImage(
      imageUrl: imageUrl,
      height: height,
      alignment: alignment,
      fit: fit,
      width: width,
      fadeOutDuration: actualFadeOutDuration,
      placeholderFadeInDuration: actualPlaceholderFadeInDuration,
      fadeInDuration: actualFadeInDuration,
      useOldImageOnUrlChange: actualUseOldImageOnUrlChange,
      matchTextDirection: matchTextDirection,
      placeholder: (context, url) => _createPlaceholder(
        actualPlaceholder,
        width,
        height,
        placeholderFit,
      ),
      errorWidget: (context, url, error) {
        return errorBuilder?.call(
                context, url, StackTrace.fromString(error.toString())) ??
            _createPlaceholder(
              actualPlaceholder,
              width,
              height,
              placeholderFit,
            );
      },
    );

    return _applyBorderRadius(
      imageWidget,
      width: width,
      height: height,
      radius: radius,
      borderRadius: borderRadius,
      circular: circular,
      border: border,
    );
  }

  /// 加载本地资源图片
  /// [name] 资源名称
  /// [isRe] 是否使用特殊路径，如果为null则使用全局配置
  /// [circular] 是否设置为圆形
  /// [radius] 圆角半径
  /// [borderRadius] 自定义圆角
  static Widget asset(
    String name, {
    Key? key,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    Color? color,
    double? scale,
    double? width,
    double? height,
    Animation<double>? opacity,
    BoxFit? fit = BoxFit.cover,
    BlendMode? colorBlendMode,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    AlignmentGeometry alignment = Alignment.center,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool isAntiAlias = false,
    bool gaplessPlayback = false,
    int? cacheWidth,
    int? cacheHeight,
    FilterQuality filterQuality = FilterQuality.medium,
    bool? isRe,
    bool circular = false,
    double? radius,
    BorderRadius? borderRadius,
    BoxBorder? border,
  }) {
    // 确定是否使用特殊路径
    final shouldUseRe = isRe ?? _config.isRe;
    // final resourcePath = shouldUseRe ? _getResourcePath(name) : name;

    Widget imageWidget;

    if (shouldUseRe) {
      imageWidget = Image.memory(
        imgCache[name] ?? kTransparentImage,
        key: key,
        frameBuilder: frameBuilder,
        errorBuilder: errorBuilder,
        semanticLabel: semanticLabel,
        excludeFromSemantics: excludeFromSemantics,
        scale: scale ?? 1.0,
        width: width,
        height: height,
        color: color,
        opacity: opacity,
        colorBlendMode: colorBlendMode,
        fit: fit,
        alignment: alignment,
        repeat: repeat,
        centerSlice: centerSlice,
        matchTextDirection: matchTextDirection,
        gaplessPlayback: gaplessPlayback,
        isAntiAlias: isAntiAlias,
        filterQuality: filterQuality,
        cacheWidth: cacheWidth,
        cacheHeight: cacheHeight,
      );
    } else {
      imageWidget = Image.asset(
        name,
        key: key,
        frameBuilder: frameBuilder,
        errorBuilder: errorBuilder,
        semanticLabel: semanticLabel,
        excludeFromSemantics: excludeFromSemantics,
        color: color,
        opacity: opacity,
        scale: scale,
        width: width,
        height: height,
        alignment: alignment,
        repeat: repeat,
        colorBlendMode: colorBlendMode,
        fit: fit,
        centerSlice: centerSlice,
        isAntiAlias: isAntiAlias,
        filterQuality: filterQuality,
        matchTextDirection: matchTextDirection,
        gaplessPlayback: gaplessPlayback,
        cacheWidth: cacheWidth,
        cacheHeight: cacheHeight,
      );
    }

    return _applyBorderRadius(
      imageWidget,
      width: width,
      height: height,
      radius: radius,
      borderRadius: borderRadius,
      circular: circular,
      border: border,
    );
  }

  ///预加载图片
  static void preloadNetworkImage(
      String? imageUrl, BuildContext context, ImageStreamListener? listener) {
    if (imageUrl == null || imageUrl.trim().isEmpty) return;
    final CachedNetworkImageProvider imageProvider =
        CachedNetworkImageProvider(imageUrl);
    final ImageStream imageStream =
        imageProvider.resolve(createLocalImageConfiguration(context));
    if (listener != null) {
      imageStream.addListener(listener);
    }
  }

  /// 获取图片提供者
  /// [name] 资源名称
  /// [isRe] 是否使用特殊路径，如果为null则使用全局配置
  static ImageProvider imageProvider(String name, {bool? isRe}) {
    final shouldUseRe = isRe ?? _config.isRe;
    // final resourcePath = shouldUseRe ? _getResourcePath(name) : name;

    if (shouldUseRe) {
      // return FileImage(File(resourcePath));
      return MemoryImage(imgCache[name] ?? kTransparentImage);
    }
    return AssetImage(name);
  }

  /// 便捷方法：加载网络图片（使用全局配置）
  /// [circular] 是否设置为圆形
  /// [radius] 圆角半径
  /// [borderRadius] 自定义圆角
  static Widget network(
    String? imageUrl, {
    double? size,
    double? width,
    double? height,
    String? placeholder,
    BoxFit? fit = BoxFit.cover,
    Alignment alignment = Alignment.center,
    bool circular = false,
    double? radius,
    BorderRadius? borderRadius,
    BoxBorder? border,
  }) {
    return cachedNetwork(
      imageUrl,
      width: size ?? width,
      height: size ?? height,
      placeholder: placeholder,
      fit: fit,
      alignment: alignment,
      circular: circular,
      radius: radius,
      borderRadius: borderRadius,
      border: border,
    );
  }

  /// 便捷方法：加载本地图片（使用全局配置）
  /// [circular] 是否设置为圆形
  /// [radius] 圆角半径
  /// [borderRadius] 自定义圆角
  static Widget local(
    String name, {
    double? size,
    double? width,
    double? height,
    BoxFit? fit = BoxFit.cover,
    bool? isRe,
    bool matchTextDirection = false,
    bool circular = false,
    double? radius,
    BorderRadius? borderRadius,
    BoxBorder? border,
  }) {
    return asset(
      name,
      width: size ?? width,
      height: size ?? height,
      fit: fit,
      isRe: isRe,
      matchTextDirection: matchTextDirection,
      circular: circular,
      radius: radius,
      borderRadius: borderRadius,
      border: border,
    );
  }

  /// 加载文件图片
  static Widget file(
    String localPath, {
    double? size,
    double? width,
    double? height,
    Key? key,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    Color? color,
    double? scale,
    Animation<double>? opacity,
    BoxFit? fit = BoxFit.cover,
    BlendMode? colorBlendMode,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    AlignmentGeometry alignment = Alignment.center,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool isAntiAlias = false,
    bool gaplessPlayback = false,
    int? cacheWidth,
    int? cacheHeight,
    FilterQuality filterQuality = FilterQuality.medium,
    String? placeholder,
    bool circular = false,
    double? radius,
    BorderRadius? borderRadius,
    BoxBorder? border,
  }) {
    Widget imageWidget = Image.file(
      File(localPath),
      key: key,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      width: size ?? width,
      height: size ?? height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );

    return _applyBorderRadius(
      imageWidget,
      width: width,
      height: height,
      radius: radius,
      borderRadius: borderRadius,
      circular: circular,
      border: border,
    );
  }

  /// 从Uint8List数据加载图片
  /// [bytes] 图片的字节数据
  /// [width] 图片视图宽
  /// [height] 图片视图高
  /// [fit] 图片填充方式
  /// [circular] 是否设置为圆形
  /// [radius] 圆角半径
  /// [borderRadius] 自定义圆角
  static Widget memory(
    Uint8List bytes, {
    double? size,
    double? width,
    double? height,
    int? cacheWidth,
    int? cacheHeight,
    Key? key,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    Color? color,
    double? scale,
    Animation<double>? opacity,
    BoxFit? fit = BoxFit.cover,
    BlendMode? colorBlendMode,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    AlignmentGeometry alignment = Alignment.center,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool isAntiAlias = false,
    bool gaplessPlayback = false,
    FilterQuality filterQuality = FilterQuality.medium,
    bool circular = false,
    double? radius,
    BorderRadius? borderRadius,
    BoxBorder? border,
  }) {
    Widget imageWidget = Image.memory(
      bytes,
      key: key,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      width: size ?? width,
      height: size ?? height,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
      color: color,
      opacity: opacity,
      scale: scale ?? 1.0,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      filterQuality: filterQuality,
    );

    return _applyBorderRadius(
      imageWidget,
      width: width,
      height: height,
      radius: radius,
      borderRadius: borderRadius,
      circular: circular,
      border: border,
    );
  }
}
