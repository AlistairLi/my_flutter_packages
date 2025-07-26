import 'package:flutter/material.dart';
import 'package:smart_refresh_list/smart_refresh_list.dart';

/// 图片数据模型
class ImageItem {
  final String id;
  final String url;
  final String title;
  final String description;

  ImageItem({
    required this.id,
    required this.url,
    required this.title,
    required this.description,
  });
}

/// 模拟API服务
class ImageApiService {
  static Future<PageData<ImageItem>> getImages({
    required int page,
    int pageSize = 20,
  }) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 500));

    // 模拟数据
    final images = List.generate(
      pageSize,
      (index) => ImageItem(
        id: '${page}_$index',
        url: 'https://picsum.photos/200/200?random=${page * pageSize + index}',
        title: '图片 ${page * pageSize + index + 1}',
        description: '这是第 ${page * pageSize + index + 1} 张图片的描述',
      ),
    );

    // 模拟分页逻辑
    final hasMore = page < 5; // 只有5页数据

    return PageData(
      data: images,
      page: page,
      pageSize: pageSize,
      hasMoreChecker: (data) => hasMore,
    );
  }
}

/// 图片网格项组件
class ImageGridItem extends StatelessWidget {
  final ImageItem image;

  const ImageGridItem({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              child: Image.network(
                image.url,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.error),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  image.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  image.description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 图片网格页面
class ImageGridPage extends StatelessWidget {
  const ImageGridPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('图片网格示例'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SmartRefreshGrid<ImageItem>(
        onRefresh: () => ImageApiService.getImages(page: 1),
        onLoad: (page) => ImageApiService.getImages(page: page),
        itemBuilder: (context, image, index) => ImageGridItem(image: image),
        crossAxisCount: 2,
        mainAxisSpacing: 8.0,
        crossAxisSpacing: 8.0,
        childAspectRatio: 0.8,
        padding: const EdgeInsets.all(16.0),
        emptyWidget: const DefaultEmptyStatusWidget(
          message: '暂无图片',
        ),
        errorWidget: const DefaultEmptyStatusWidget(
          message: '加载失败',
        ),
        onError: (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('错误: $error')),
          );
        },
      ),
    );
  }
}

/// 自适应网格示例
class AdaptiveGridPage extends StatelessWidget {
  const AdaptiveGridPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('自适应网格示例'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SmartRefreshGrid<ImageItem>(
        onRefresh: () => ImageApiService.getImages(page: 1),
        onLoad: (page) => ImageApiService.getImages(page: page),
        itemBuilder: (context, image, index) => ImageGridItem(image: image),
        maxCrossAxisExtent: 180.0,
        mainAxisSpacing: 8.0,
        crossAxisSpacing: 8.0,
        childAspectRatio: 0.8,
        padding: const EdgeInsets.all(16.0),
        emptyWidget: const DefaultEmptyStatusWidget(
          message: '暂无图片',
        ),
        errorWidget: const DefaultEmptyStatusWidget(
          message: '加载失败',
        ),
        onError: (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('错误: $error')),
          );
        },
      ),
    );
  }
}

/// 自定义网格代理示例
class CustomGridPage extends StatelessWidget {
  const CustomGridPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('自定义网格代理示例'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SmartRefreshGrid<ImageItem>(
        onRefresh: () => ImageApiService.getImages(page: 1),
        onLoad: (page) => ImageApiService.getImages(page: page),
        itemBuilder: (context, image, index) => ImageGridItem(image: image),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 12.0,
          crossAxisSpacing: 12.0,
          childAspectRatio: 0.7,
        ),
        padding: const EdgeInsets.all(16.0),
        emptyWidget: const DefaultEmptyStatusWidget(
          message: '暂无图片',
        ),
        errorWidget: const DefaultEmptyStatusWidget(
          message: '加载失败',
        ),
        onError: (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('错误: $error')),
          );
        },
      ),
    );
  }
} 