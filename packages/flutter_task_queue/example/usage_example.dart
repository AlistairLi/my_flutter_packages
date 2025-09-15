import 'package:flutter_task_queue/flutter_task_queue.dart';
import 'dart:io';

void main() async {
  // 创建串行任务队列
  final serialQueue = TaskQueueFactory.serial<String>();
  
  // 创建并行任务队列
  final parallelQueue = TaskQueueFactory.parallel<String>(maxJobs: 3);
  
  // 示例1: 基本使用
  await basicUsageExample(serialQueue);
  
  // 示例2: 任务取消
  await cancellationExample(parallelQueue);
  
  // 示例3: 批量任务处理
  await batchTaskExample(parallelQueue);
  
  // 示例4: 重试和延迟
  await retryAndDelayExample(serialQueue);
}

/// 基本使用示例
Future<void> basicUsageExample(SimpleTaskQueue<String> queue) async {
  print('=== 基本使用示例 ===');
  
  final result = await queue.add((cancelToken) async {
    // 模拟一些工作
    await Future.delayed(Duration(seconds: 1));
    return '任务完成';
  });
  
  if (result.isSuccess) {
    print('任务成功: ${result.value}');
  } else if (result.isCancelled) {
    print('任务被取消: ${result.cancelReason}');
  } else if (result.isError) {
    print('任务失败: ${result.error}');
  }
}

/// 任务取消示例
Future<void> cancellationExample(SimpleTaskQueue<String> queue) async {
  print('\n=== 任务取消示例 ===');
  
  // 添加一个长时间运行的任务
  final future = queue.add((cancelToken) async {
    for (int i = 0; i < 10; i++) {
      // 检查是否被取消
      if (cancelToken?.isCancelled == true) {
        throw Exception('任务被取消');
      }
      await Future.delayed(Duration(milliseconds: 500));
      print('任务进度: ${i + 1}/10');
    }
    return '长时间任务完成';
  });
  
  // 2秒后取消所有任务
  Future.delayed(Duration(seconds: 2), () {
    print('取消所有任务...');
    queue.cancelAllTasks();
  });
  
  final result = await future;
  if (result.isCancelled) {
    print('任务被取消: ${result.cancelReason}');
  }
}

/// 批量任务处理示例
Future<void> batchTaskExample(SimpleTaskQueue<String> queue) async {
  print('\n=== 批量任务处理示例 ===');
  
  final tasks = List.generate(5, (index) => (cancelToken) async {
    await Future.delayed(Duration(milliseconds: 500));
    return '任务 ${index + 1} 完成';
  });
  
  final results = await queue.waitForAll(tasks);
  
  int successCount = 0;
  int cancelledCount = 0;
  int errorCount = 0;
  
  for (final result in results) {
    if (result.isSuccess) {
      successCount++;
      print('成功: ${result.value}');
    } else if (result.isCancelled) {
      cancelledCount++;
      print('取消: ${result.cancelReason}');
    } else if (result.isError) {
      errorCount++;
      print('错误: ${result.error}');
    }
  }
  
  print('批量任务结果: 成功 $successCount, 取消 $cancelledCount, 错误 $errorCount');
}

/// 重试和延迟示例
Future<void> retryAndDelayExample(SimpleTaskQueue<String> queue) async {
  print('\n=== 重试和延迟示例 ===');
  
  // 延迟任务
  final delayedResult = await queue.addDelayed(
    (cancelToken) async => '延迟任务完成',
    Duration(seconds: 1),
  );
  
  if (delayedResult.isSuccess) {
    print('延迟任务: ${delayedResult.value}');
  }
  
  // 重试任务
  int attemptCount = 0;
  final retryResult = await queue.addWithRetry(
    (cancelToken) async {
      attemptCount++;
      print('尝试第 $attemptCount 次');
      
      // 前两次失败，第三次成功
      if (attemptCount < 3) {
        throw Exception('模拟失败');
      }
      
      return '重试任务成功';
    },
    maxRetries: 3,
    retryDelay: Duration(milliseconds: 500),
  );
  
  if (retryResult.isSuccess) {
    print('重试任务: ${retryResult.value}');
  } else if (retryResult.isError) {
    print('重试任务失败: ${retryResult.error}');
  }
}

/// 网络请求集成示例
Future<void> networkRequestExample(SimpleTaskQueue<String> queue) async {
  print('\n=== 网络请求集成示例 ===');
  
  final result = await queue.add((cancelToken) async {
    // 模拟网络请求
    final client = HttpClient();
    
    // 注册取消回调
    cancelToken?.addCancelCallback(() {
      client.close();
    });
    
    try {
      // 检查是否被取消
      if (cancelToken?.isCancelled == true) {
        throw Exception('请求被取消');
      }
      
      // 模拟网络延迟
      await Future.delayed(Duration(seconds: 2));
      
      // 再次检查是否被取消
      if (cancelToken?.isCancelled == true) {
        throw Exception('请求被取消');
      }
      
      return '网络请求成功';
    } finally {
      client.close();
    }
  });
  
  if (result.isSuccess) {
    print('网络请求: ${result.value}');
  } else if (result.isCancelled) {
    print('网络请求被取消: ${result.cancelReason}');
  }
}
