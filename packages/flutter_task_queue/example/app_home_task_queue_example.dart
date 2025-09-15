import 'package:flutter_task_queue/flutter_task_queue.dart';

void main() async {
  AppHomeTaskQueueExample.start();
}

class AppHomeTaskQueueExample {
  AppHomeTaskQueueExample._();

  static final SimpleTaskQueue<void> taskQueue = SimpleTaskQueue();
  static bool tasksCompleted = false;

  static void start() async {
    List<TaskClosure<void>> tasks = [];
    tasks.add((cancelToken) {
      return _task1(cancelToken);
    });
    tasks.add((cancelToken) {
      return _task2(cancelToken);
    });
    tasks.add((cancelToken) {
      return _task3(cancelToken);
    });
    taskQueue.addAll(tasks);
    taskQueue.allTasksComplete.then((_) {
      tasksCompleted = true;

    });
  }

  static void reset() {
    tasksCompleted = false;
    taskQueue.cancelAllTasks();
  }

  static Future<void> _task1(CancellationToken? cancelToken) async {
    if (cancelToken?.isCancelled == true) {
      print("_task1, 任务队列已取消");
      return;
    }
    await Future.delayed(Duration(seconds: 10));
    return;
  }

  static Future<void> _task2(CancellationToken? cancelToken) async {
    if (cancelToken?.isCancelled == true) {
      print("_task2, 任务队列已取消");
      return;
    }
    await Future.delayed(Duration(seconds: 5));
    return;
  }

  static Future<void> _task3(CancellationToken? cancelToken) async {
    if (cancelToken?.isCancelled == true) {
      print("_task3, 任务队列已取消");
      return;
    }
    await Future.delayed(Duration(seconds: 5));
    return;
  }
}
