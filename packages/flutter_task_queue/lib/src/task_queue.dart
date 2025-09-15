// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:collection';

/// A closure type used by the [TaskQueue].
typedef TaskQueueClosure<T> = Future<T> Function();

/// A task queue of Futures to be completed in parallel, throttling
/// the number of simultaneous tasks.
///
/// The tasks return results of type T.
/// 一个并行完成的 `Future` 任务队列，限制同时执行的任务数量。任务返回类型为 T 的结果。
class TaskQueue<T> {
  /// Creates a task queue with a maximum number of simultaneous jobs.
  /// The [maxJobs] parameter defaults to the number of CPU cores on the
  /// system.
  TaskQueue({int? maxJobs}) : maxJobs = maxJobs ?? 1;

  /// The maximum number of jobs that this queue will run simultaneously.
  final int maxJobs;

  final Queue<_TaskQueueItem<T>> _pendingTasks = Queue<_TaskQueueItem<T>>();
  final Set<_TaskQueueItem<T>> _activeTasks = <_TaskQueueItem<T>>{};
  final Set<Completer<void>> _completeListeners = <Completer<void>>{};

  /// Returns a future that completes when all tasks in the [TaskQueue] are
  /// complete.
  /// 返回一个在 [TaskQueue] 中的所有任务都完成时完成的 Future。
  Future<void> get tasksComplete {
    // In case this is called when there are no tasks, we want it to
    // signal complete immediately.
    // 如果在没有任务的情况下调用此程序，我们希望它能立即显示已完成状态。
    if (_activeTasks.isEmpty && _pendingTasks.isEmpty) {
      return Future<void>.value();
    }
    final Completer<void> completer = Completer<void>();
    _completeListeners.add(completer);
    return completer.future;
  }

  /// Adds a single closure to the task queue, returning a future that
  /// completes when the task completes.
  /// 将一个闭包添加到任务队列中，并返回一个 Future，当任务完成时该 Future 会完成。
  Future<T> add(TaskQueueClosure<T> task) {
    final Completer<T> completer = Completer<T>();
    _pendingTasks.add(_TaskQueueItem<T>(task, completer));
    if (_activeTasks.length < maxJobs) {
      _processTask();
    }
    return completer.future;
  }

  // Process a single task.
  void _processTask() {
    if (_pendingTasks.isNotEmpty && _activeTasks.length <= maxJobs) {
      final _TaskQueueItem<T> item = _pendingTasks.removeFirst();
      _activeTasks.add(item);
      item.onComplete = () {
        _activeTasks.remove(item);
        _processTask();
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

class _TaskQueueItem<T> {
  _TaskQueueItem(this._closure, this._completer, {this.onComplete});

  final TaskQueueClosure<T> _closure;
  final Completer<T> _completer;
  void Function()? onComplete;

  Future<void> run() async {
    try {
      _completer.complete(await _closure());
    } catch (e) {
      // ignore: avoid_catches_without_on_clauses, forwards to Future
      _completer.completeError(e);
    } finally {
      onComplete?.call();
    }
  }
}
