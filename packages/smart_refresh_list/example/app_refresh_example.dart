import 'package:smart_refresh_list/smart_refresh_list.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Refresh Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

/// 示例数据模型
class Article {
  final int id;
  final String title;
  final String content;
  final DateTime createdAt;

  Article({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'] as int,
      title: json['title'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

/// 模拟API服务
class ApiService {
  static Future<PageData<Article>> getArticles(
      {int page = 1, int pageSize = 20}) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 1000));

    // 模拟数据
    final articles = List.generate(
      pageSize,
      (index) => Article(
        id: (page - 1) * pageSize + index + 1,
        title: '文章标题 ${(page - 1) * pageSize + index + 1}',
        content: '这是第 ${(page - 1) * pageSize + index + 1} 篇文章的内容...',
        createdAt: DateTime.now().subtract(Duration(days: index)),
      ),
    );

    // 模拟分页逻辑
    final hasMore = page < 5; // 只有5页数据

    return PageData(
      data: articles,
      page: page,
      pageSize: pageSize,
    );
  }
}

/// 文章列表项组件
class ArticleTile extends StatelessWidget {
  final Article article;

  const ArticleTile({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        title: Text(
          article.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(article.content),
            const SizedBox(height: 8),
            Text(
              '创建时间: ${article.createdAt.toString().substring(0, 19)}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('点击了: ${article.title}')),
          );
        },
      ),
    );
  }
}

/// 主页面
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Refresh 示例'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // 添加测试按钮
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // 这里可以添加手动刷新逻辑
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('手动刷新触发')),
              );
            },
          ),
        ],
      ),
      body: const ArticleListPage(),
    );
  }
}

/// 文章列表页面 - 使用 AppRefreshList
class ArticleListPage extends StatelessWidget {
  const ArticleListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SmartRefreshList<Article>(
      onRefresh: () => ApiService.getArticles(page: 1),
      onLoad: (page) => ApiService.getArticles(page: page),
      itemBuilder: (context, article, index) => ArticleTile(article: article),
      separatorBuilder: (context, index) => const Divider(height: 1),
      emptyWidget: const DefaultEmptyStatusWidget(
        message: '暂无文章',
      ),
      errorWidget: const ErrorStateWidget(),
      onError: (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载失败: $error')),
        );
      },
    );
  }
}

/// 错误状态组件
class ErrorStateWidget extends StatelessWidget {
  const ErrorStateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[300],
          ),
          const SizedBox(height: 16),
          const Text(
            '加载失败',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('请检查网络连接后重试'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // 这里可以添加重试逻辑
            },
            child: const Text('重试'),
          ),
        ],
      ),
    );
  }
}
