# Image Loader Package

一个功能强大的 Flutter 图片加载工具包，支持网络图片、本地资源加载，支持加密本地资源的加载。
在这个库中，通过函数式返回 Widget的方式更好，简单易用。


## ✨ 特性

- 🌐 **网络图片缓存** - 基于 `cached_network_image` 的网络图片加载和缓存
- 📁 **本地资源加载** - 支持普通资源和加密资源的加载
- ⚙️ **全局配置** - 可配置默认占位图、资源加密路径等
- 🎯 **灵活配置** - 支持全局配置和单次调用配置
- 🚀 **便捷方法** - 提供简化的 API 接口

## 🚀 快速开始

### 1. 添加依赖

```yaml
dependencies:
  image_loader:
    path: packages/image_loader
```

### 2. 配置全局设置（可选）

```dart
// 在应用启动时配置
ImageUtil.setConfig(
    ImageLoaderConfig.custom(
    defaultPlaceholder: 'assets/images/placeholder.png',
    isResEncryption: true,
    resEncryptionOutDir: '/data/data/com.example.app/files/assets',
    defaultPlaceholderFit: BoxFit.contain,
    defaultNetworkImageFit: BoxFit.cover,
    ),
);
```