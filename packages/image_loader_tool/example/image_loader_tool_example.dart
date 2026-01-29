import 'package:flutter/material.dart';
import 'package:image_loader_tool/image_loader_tool.dart';

/// ImageUtil 使用示例
class ImageUtilToolExample extends StatelessWidget {
  const ImageUtilToolExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ImageUtil 使用示例'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 配置示例
            _buildSectionTitle('1. 全局配置'),
            _buildConfigExample(),

            const SizedBox(height: 32),

            // 网络图片示例
            _buildSectionTitle('2. 网络图片加载'),
            _buildNetworkImageExamples(),

            const SizedBox(height: 32),

            // 本地图片示例
            _buildSectionTitle('3. 本地图片加载'),
            _buildLocalImageExamples(),

            const SizedBox(height: 32),

            // 便捷方法示例
            _buildSectionTitle('4. 便捷方法'),
            _buildConvenienceExamples(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.blue,
      ),
    );
  }

  Widget _buildConfigExample() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('配置全局设置：'),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                // 配置默认占位图和资源加密
                ImageLoader.setConfig(
                  ImageLoaderConfig.custom(
                    defaultPlaceholder: 'assets/images/placeholder.png',
                    isRe: true,
                    resEncryptionOutDir:
                        '/data/data/com.example.app/files/assets',
                  ),
                );
              },
              child: const Text('设置全局配置'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                // 重置为默认配置
                ImageLoader.setConfig(ImageLoaderConfig.defaultConfig());
              },
              child: const Text('重置为默认配置'),
            ),
            const SizedBox(height: 8),
            Text('当前配置：${ImageLoader.config.toString()}'),
          ],
        ),
      ),
    );
  }

  Widget _buildNetworkImageExamples() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('使用全局配置的占位图：'),
            const SizedBox(height: 8),
            ImageLoader.cachedNetwork(
              'https://picsum.photos/200/200',
              width: 100,
              height: 100,
            ),
            const SizedBox(height: 16),
            const Text('自定义占位图：'),
            const SizedBox(height: 8),
            ImageLoader.cachedNetwork(
              'https://picsum.photos/200/200',
              width: 100,
              height: 100,
              placeholder: 'assets/images/custom_placeholder.png',
              placeholderFit: BoxFit.contain,
            ),
            const SizedBox(height: 16),
            const Text('自定义适配方式：'),
            const SizedBox(height: 8),
            ImageLoader.cachedNetwork(
              'https://picsum.photos/200/100',
              width: 200,
              height: 100,
              fit: BoxFit.contain,
              placeholder: 'assets/images/placeholder.png',
            ),
            const SizedBox(height: 16),
            const Text('使用便捷方法：'),
            const SizedBox(height: 8),
            ImageLoader.network(
              'https://picsum.photos/150/150',
              width: 100,
              height: 100,
              placeholder: 'assets/images/placeholder.png',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocalImageExamples() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('普通资源图片：'),
            const SizedBox(height: 8),
            ImageLoader.asset(
              'assets/images/logo.png',
              width: 100,
              height: 100,
            ),
            const SizedBox(height: 16),
            const Text('加密资源图片（使用全局配置）：'),
            const SizedBox(height: 8),
            ImageLoader.asset(
              'assets/images/encrypted_logo.png',
              width: 100,
              height: 100,
            ),
            const SizedBox(height: 16),
            const Text('强制使用加密路径：'),
            const SizedBox(height: 8),
            ImageLoader.asset(
              'assets/images/logo.png',
              width: 100,
              height: 100,
              isRe: true,
            ),
            const SizedBox(height: 16),
            const Text('强制使用普通路径：'),
            const SizedBox(height: 8),
            ImageLoader.asset(
              'assets/images/logo.png',
              width: 100,
              height: 100,
              isRe: false,
            ),
            const SizedBox(height: 16),
            const Text('使用便捷方法：'),
            const SizedBox(height: 8),
            ImageLoader.local(
              'assets/images/logo.png',
              width: 100,
              height: 100,
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConvenienceExamples() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('网络图片便捷方法：'),
            const SizedBox(height: 8),
            Row(
              children: [
                ImageLoader.network(
                  'https://picsum.photos/100/100?random=1',
                  width: 80,
                  height: 80,
                ),
                const SizedBox(width: 8),
                ImageLoader.network(
                  'https://picsum.photos/100/100?random=2',
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
                const SizedBox(width: 8),
                ImageLoader.network(
                  'https://picsum.photos/100/100?random=3',
                  width: 80,
                  height: 80,
                  fit: BoxFit.contain,
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('本地图片便捷方法：'),
            const SizedBox(height: 8),
            Row(
              children: [
                ImageLoader.local(
                  'assets/images/icon1.png',
                  width: 80,
                  height: 80,
                ),
                const SizedBox(width: 8),
                ImageLoader.local(
                  'assets/images/icon2.png',
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
                const SizedBox(width: 8),
                ImageLoader.local(
                  'assets/images/icon3.png',
                  width: 80,
                  height: 80,
                  fit: BoxFit.contain,
                  isRe: true,
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('图片提供者：'),
            const SizedBox(height: 8),
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image:
                      ImageLoader.imageProvider('assets/images/background.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 使用示例
void main() {
  runApp(const MaterialApp(
    home: ImageUtilToolExample(),
  ));
}
