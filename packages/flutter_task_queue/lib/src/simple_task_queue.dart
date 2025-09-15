import 'dart:async';
import 'dart:collection';

/// [SimpleTaskQueue] 使用的closure
typedef TaskClosure<T> = Future<T> Function(CancellationToken? cancelToken);

/// 任务执行结果
class TaskResult<T> {
  const TaskResult();

  /// 是否成功
  bool get isSuccess => this is TaskResultSuccess<T>;

  /// 是否被取消
  bool get isCancelled => this is TaskResultCancelled<T>;

  /// 是否有错误
  bool get isError => this is TaskResultError<T>;

  /// 获取成功值，如果不是成功结果则返回null
  T? get value => isSuccess ? (this as TaskResultSuccess<T>).value : null;

  /// 获取错误信息，如果不是错误结果则返回null
  String? get error => isError ? (this as TaskResultError<T>).error : null;

  /// 获取取消原因，如果不是取消结果则返回null
  String? get cancelReason =>
      isCancelled ? (this as TaskResultCancelled<T>).reason : null;
}

/// 任务成功结果
class TaskResultSuccess<T> extends TaskResult<T> {
  const TaskResultSuccess(this.value);

  @override
  final T value;

  @override
  String toString() => 'TaskResultSuccess($value)';
}

/// 任务取消结果
class TaskResultCancelled<T> extends TaskResult<T> {
  const TaskResultCancelled(this.reason);

  final String reason;

  @override
  String toString() => 'TaskResultCancelled($reason)';
}

/// 任务错误结果
class TaskResultError<T> extends TaskResult<T> {
  const TaskResultError(this.error);

  @override
  final String error;

  @override
  String toString() => 'TaskResultError($error)';
}

/// 取消令牌，用于取消任务
class CancellationToken {
  CancellationToken();

  bool _isCancelled = false;
  final List<Function()> _cancelCallbacks = [];

  /// 是否已取消
  bool get isCancelled => _isCancelled;

  /// 添加取消回调
  void addCancelCallback(Function() callback) {
    if (_isCancelled) {
      callback();
    } else {
      _cancelCallbacks.add(callback);
    }
  }

  /// 取消任务
  void cancel([String? reason]) {
    if (_isCancelled) return;

    _isCancelled = true;

    // 执行所有取消回调
    for (final callback in _cancelCallbacks) {
      try {
        callback();
      } catch (e) {
        // 忽略取消回调中的异常
      }
    }
    _cancelCallbacks.clear();
  }

  /// 检查是否已取消，如果已取消则抛出异常
  void throwIfCancelled([String? message]) {
    if (_isCancelled) {
      throw Exception(message ?? 'Task was cancelled');
    }
  }
}

/// 简单的任务队列
/// 1. 可并行，可串行
/// 2. 支持任务取消功能（包括网络请求和其他任务）
class SimpleTaskQueue<T> {
  SimpleTaskQueue({int? maxJobs}) : maxJobs = maxJobs ?? 1;

  /// 队列可同时运行的最大作业数。值设置1就是串行
  final int maxJobs;

  final Queue<_TaskQueueItem<T>> _pendingTasks = Queue<_TaskQueueItem<T>>();
  final Set<_TaskQueueItem<T>> _activeTasks = <_TaskQueueItem<T>>{};
  final Set<Completer<void>> _completeListeners = <Completer<void>>{};

  bool _canceled = false;

  /// 当 [SimpleTaskQueue] 中的所有任务都完成时，返回一个完成的future
  Future<void> get allTasksComplete {
    // 如果在没有任务的情况下调用此方法，我们希望它立即发出完成信号。
    if (_activeTasks.isEmpty && _pendingTasks.isEmpty) {
      return Future<void>.value();
    }
    final Completer<void> completer = Completer<void>();
    _completeListeners.add(completer);
    return completer.future;
  }

  /// 获取当前活跃任务数量
  int get activeTaskCount => _activeTasks.length;

  /// 获取等待中的任务数量
  int get pendingTaskCount => _pendingTasks.length;

  /// 获取总任务数量
  int get totalTaskCount => activeTaskCount + pendingTaskCount;

  /// 检查队列是否为空
  bool get isEmpty => _activeTasks.isEmpty && _pendingTasks.isEmpty;

  /// 检查队列是否忙碌
  bool get isBusy => _activeTasks.isNotEmpty || _pendingTasks.isNotEmpty;

  /// 取消所有任务
  void cancelAllTasks() {
    _canceled = true;
    final tasksToCancel = Set<_TaskQueueItem<T>>.from(_activeTasks);
    for (final task in tasksToCancel) {
      task.cancel();
    }
    _activeTasks.clear();
    _pendingTasks.clear();
    _checkForCompletion();

    // 延迟重置取消标志，确保所有取消操作完成
    Future.microtask(() {
      _canceled = false;
    });
  }

  /// 在任务队列中添加一个闭包，当任务完成后，返回一个TaskResult
  Future<TaskResult<T>> add(TaskClosure<T> task) {
    final Completer<TaskResult<T>> completer = Completer<TaskResult<T>>();
    if (_canceled) {
      completer.complete(const TaskResultCancelled('Task queue was cancelled'));
      return completer.future;
    }
    final CancellationToken cancelToken = CancellationToken();
    _pendingTasks.add(_TaskQueueItem<T>(
      task,
      completer,
      cancelToken: cancelToken,
    ));
    if (_activeTasks.length < maxJobs) {
      _processTask();
    }
    return completer.future;
  }

  /// 批量添加任务
  List<Future<TaskResult<T>>> addAll(List<TaskClosure<T>> tasks) {
    return tasks.map((task) => add(task)).toList();
  }

  /// 等待所有任务完成
  Future<List<TaskResult<T>>> waitForAll(List<TaskClosure<T>> tasks) async {
    final futures = addAll(tasks);
    return Future.wait(futures);
  }

  /// 处理单个任务
  void _processTask() {
    if (_pendingTasks.isNotEmpty && _activeTasks.length < maxJobs) {
      // if (_pendingTasks.isNotEmpty && _activeTasks.isEmpty) { // 代码改成这样也可以实现串行
      final _TaskQueueItem<T> item = _pendingTasks.removeFirst();
      _activeTasks.add(item);
      item.onComplete = () {
        try {
          _activeTasks.remove(item);
          _processTask();
        } catch (e) {
          // 记录错误但不影响其他任务
          print('Error in task completion: $e');
        }
      };
      item.run();
    } else {
      _checkForCompletion();
    }
  }

  void _checkForCompletion() {
    if (_activeTasks.isEmpty && _pendingTasks.isEmpty) {
      for (final Completer<void> completer in _completeListeners) {
        if (!completer.isCompleted) {
          completer.complete();
        }
      }
      _completeListeners.clear();
    }
  }
}

/// 任务项
class _TaskQueueItem<T> {
  _TaskQueueItem(
    this._closure,
    this._completer, {
    this.onComplete,
    this.cancelToken,
  });

  final TaskClosure<T> _closure;
  final Completer<TaskResult<T>> _completer;
  void Function()? onComplete;

  bool _canceled = false;
  final CancellationToken? cancelToken;

  Future<void> run() async {
    try {
      // 在任务运行前检查是否取消
      if (_canceled) {
        if (!_completer.isCompleted) {
          _completer.complete(const TaskResultCancelled('Task was cancelled'));
        }
        return;
      }

      // 检查取消令牌
      if (cancelToken?.isCancelled == true) {
        if (!_completer.isCompleted) {
          _completer.complete(const TaskResultCancelled('Task was cancelled'));
        }
        return;
      }

      // 执行任务
      final result = await _closure(cancelToken);
      if (!_completer.isCompleted) {
        _completer.complete(TaskResultSuccess<T>(result));
      }
    } catch (e) {
      if (!_completer.isCompleted) {
        _completer.complete(TaskResultError<T>(e.toString()));
      }
    } finally {
      onComplete?.call();
    }
  }

  void cancel() {
    _canceled = true;
    cancelToken?.cancel('Task cancelled');
    if (!_completer.isCompleted) {
      _completer.complete(const TaskResultCancelled('Task was cancelled'));
    }
    onComplete?.call();
  }
}

/// 扩展方法，提供便捷的创建方法
extension SimpleTaskQueueExtensions<T> on SimpleTaskQueue<T> {
  /// 添加延迟任务
  Future<TaskResult<T>> addDelayed(
    TaskClosure<T> task,
    Duration delay,
  ) {
    return add((cancelToken) async {
      await Future.delayed(delay);
      if (cancelToken?.isCancelled == true) {
        throw Exception('Task was cancelled during delay');
      }
      return await task(cancelToken);
    });
  }

  /// 添加重试任务
  Future<TaskResult<T>> addWithRetry(
    TaskClosure<T> task, {
    int maxRetries = 3,
    Duration? retryDelay,
  }) {
    return add((cancelToken) async {
      int attempts = 0;
      while (attempts < maxRetries) {
        try {
          if (cancelToken?.isCancelled == true) {
            throw Exception('Task was cancelled during retry');
          }
          return await task(cancelToken);
        } catch (e) {
          attempts++;
          if (attempts >= maxRetries) rethrow;
          if (retryDelay != null) {
            await Future.delayed(retryDelay);
          }
        }
      }
      throw Exception('Max retries exceeded');
    });
  }
}

/// 任务队列工厂类，提供便捷的创建方法
class TaskQueueFactory {
  /// 创建串行任务队列
  static SimpleTaskQueue<T> serial<T>() => SimpleTaskQueue<T>(maxJobs: 1);

  /// 创建并行任务队列
  static SimpleTaskQueue<T> parallel<T>({int? maxJobs}) =>
      SimpleTaskQueue<T>(maxJobs: maxJobs);
}
