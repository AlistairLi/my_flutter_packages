import 'package:flutter_task_queue/flutter_task_queue.dart';
import 'package:test/test.dart';

void main() {
  group('SimpleTaskQueue Tests', () {
    test('基本任务执行', () async {
      final queue = TaskQueueFactory.serial<String>();

      final result = await queue.add((cancelToken) async {
        return '测试成功';
      });

      expect(result.isSuccess, true);
      expect(result.value, '测试成功');
    });

    test('任务取消', () async {
      final queue = TaskQueueFactory.serial<String>();

      final future = queue.add((cancelToken) async {
        await Future.delayed(Duration(seconds: 1));
        return '不应该执行到这里';
      });

      // 立即取消
      queue.cancelAllTasks();

      final result = await future;
      expect(result.isCancelled, true);
      expect(result.cancelReason, isNotNull);
    });

    test('任务错误处理', () async {
      final queue = TaskQueueFactory.serial<String>();

      final result = await queue.add((cancelToken) async {
        throw Exception('测试错误');
      });

      expect(result.isError, true);
      expect(result.error, contains('测试错误'));
    });

    test('批量任务处理', () async {
      final queue = TaskQueueFactory.parallel<String>(maxJobs: 2);

      final tasks = List.generate(
          3,
          (index) => (cancelToken) async {
                await Future.delayed(Duration(milliseconds: 100));
                return '任务 ${index + 1}';
              });

      final results = await queue.waitForAll(tasks);

      expect(results.length, 3);
      for (final result in results) {
        expect(result.isSuccess, true);
      }
    });

    test('延迟任务', () async {
      final queue = TaskQueueFactory.serial<String>();

      final startTime = DateTime.now();
      final result = await queue.addDelayed(
        (cancelToken) async => '延迟任务',
        Duration(milliseconds: 100),
      );

      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);

      expect(result.isSuccess, true);
      expect(result.value, '延迟任务');
      expect(duration.inMilliseconds, greaterThanOrEqualTo(100));
    });

    test('重试任务', () async {
      final queue = TaskQueueFactory.serial<String>();

      int attemptCount = 0;
      final result = await queue.addWithRetry(
        (cancelToken) async {
          attemptCount++;
          if (attemptCount < 3) {
            throw Exception('模拟失败');
          }
          return '重试成功';
        },
        maxRetries: 3,
      );

      expect(result.isSuccess, true);
      expect(result.value, '重试成功');
      expect(attemptCount, 3);
    });

    test('取消令牌检查', () async {
      final queue = TaskQueueFactory.serial<String>();

      final result = await queue.add((cancelToken) async {
        // 检查取消令牌
        if (cancelToken?.isCancelled == true) {
          throw Exception('任务被取消');
        }
        return '任务完成';
      });

      expect(result.isSuccess, true);
      expect(result.value, '任务完成');
    });

    test('队列状态查询', () async {
      final queue = TaskQueueFactory.parallel<String>(maxJobs: 2);

      expect(queue.isEmpty, true);
      expect(queue.isBusy, false);
      expect(queue.activeTaskCount, 0);
      expect(queue.pendingTaskCount, 0);

      // 添加任务
      final future1 = queue.add((cancelToken) async {
        await Future.delayed(Duration(milliseconds: 100));
        return '任务1';
      });

      final future2 = queue.add((cancelToken) async {
        await Future.delayed(Duration(milliseconds: 100));
        return '任务2';
      });

      // 等待任务开始执行
      await Future.delayed(Duration(milliseconds: 10));

      expect(queue.activeTaskCount, 2);
      expect(queue.isBusy, true);

      // 等待任务完成
      await future1;
      await future2;

      expect(queue.isEmpty, true);
      expect(queue.isBusy, false);
    });
  });

  group('TaskResult Tests', () {
    test('TaskResultSuccess', () {
      const result = TaskResultSuccess<String>('测试值');

      expect(result.isSuccess, true);
      expect(result.isCancelled, false);
      expect(result.isError, false);
      expect(result.value, '测试值');
      expect(result.error, null);
      expect(result.cancelReason, null);
    });

    test('TaskResultCancelled', () {
      const result = TaskResultCancelled<String>('取消原因');

      expect(result.isSuccess, false);
      expect(result.isCancelled, true);
      expect(result.isError, false);
      expect(result.value, null);
      expect(result.error, null);
      expect(result.cancelReason, '取消原因');
    });

    test('TaskResultError', () {
      const result = TaskResultError<String>('错误信息');

      expect(result.isSuccess, false);
      expect(result.isCancelled, false);
      expect(result.isError, true);
      expect(result.value, null);
      expect(result.error, '错误信息');
      expect(result.cancelReason, null);
    });
  });

  group('CancellationToken Tests', () {
    test('基本取消功能', () {
      final token = CancellationToken();

      expect(token.isCancelled, false);

      token.cancel('测试取消');

      expect(token.isCancelled, true);
    });

    test('取消回调', () {
      final token = CancellationToken();
      bool callbackCalled = false;

      token.addCancelCallback(() {
        callbackCalled = true;
      });

      token.cancel();

      expect(callbackCalled, true);
    });

    test('取消后添加回调', () {
      final token = CancellationToken();
      bool callbackCalled = false;

      token.cancel();

      token.addCancelCallback(() {
        callbackCalled = true;
      });

      expect(callbackCalled, true);
    });

    test('throwIfCancelled', () {
      final token = CancellationToken();

      // 未取消时不应该抛出异常
      expect(() => token.throwIfCancelled(), returnsNormally);

      token.cancel();

      // 取消后应该抛出异常
      expect(() => token.throwIfCancelled(), throwsException);
    });
  });
}
