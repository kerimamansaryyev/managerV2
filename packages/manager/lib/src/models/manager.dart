import 'dart:async';

import 'package:async/async.dart';
import 'package:manager/src/models/async_task_references.dart';
import 'package:manager/src/models/task.dart';
import 'package:manager/src/models/task_event.dart';
import 'package:manager/src/models/task_mixins.dart';
import 'package:meta/meta.dart';

typedef AsyncTaskCompleterReferenceTable<T>
    = Map<String, AsyncTaskCompleterReference<T>>;

abstract class Manager<T> {
  final AsyncTaskCompleterReferenceTable<T> _references = {};
  final StreamController<T> _onStateChangedController =
      StreamController.broadcast();
  final StreamController<TaskEvent<T>> _onEventController =
      StreamController.broadcast();

  T _state;

  Manager(T initialValue) : _state = initialValue;

  T get state => _state;
  Stream<T> get onStateChanged => _onStateChangedController.stream;
  Stream<void> get onUpdated =>
      StreamGroup.mergeBroadcast([on(), onStateChanged]).map((event) {
        return;
      });
  Stream<TaskEvent<T>> on<S extends Task<T>>({String? taskId}) =>
      _onEventController.stream.where(
        (event) =>
            (taskId == null && S == Task<T>) ||
            (taskId == event.task.id && event.task is S) ||
            (taskId == null && event.task is S) ||
            (taskId == event.task.id && S == Task<T>),
      );
  AsyncTaskCompleterReference<T>? getAsyncReferenceOf({
    required String taskId,
  }) =>
      _references[safelyExtractTaskIdFromString(taskId)];

  @mustCallSuper
  void run(Task<T> task) {
    if (task is AsynchronousTask<T>) {
      _handleAsyncTask(task);
    } else if (task is SynchronousTask<T>) {
      _handleSyncTask(task);
    }
  }

  @mustCallSuper
  Future<void> killById({required String taskId}) async {
    final reference = _references[safelyExtractTaskIdFromString(taskId)];
    final task = reference?.task;
    if (task is! CancelableAsyncTaskMixin<T>) {
      return;
    }
    return kill(task);
  }

  @mustCallSuper
  void dispose() {
    _onStateChangedController.close();
    _onEventController.close();
  }

  @visibleForTesting
  String testAsyncTaskIdPivotGeneratorRaw(String taskId) =>
      safelyExtractTaskIdFromString(taskId);

  @visibleForTesting
  Future<void> waitForTaskToBeDone({required String taskId}) =>
      getAsyncReferenceOf(taskId: taskId)?.internalCompleterFuture ??
      Future.value(null);

  @mustCallSuper
  @protected
  void mutateState(T newState) {
    _state = newState;
    if (!_onStateChangedController.isClosed) {
      _onStateChangedController.add(_state);
    }
  }

  @mustCallSuper
  @protected
  void onEventCallback(TaskEvent<T> event) {}

  @mustCallSuper
  @protected
  Future<void> kill(CancelableAsyncTaskMixin<T> task) async {
    final stoppedTask =
        _stopAndReturnReference(task)?.task as CancelableAsyncTaskMixin<T>?;
    if (stoppedTask == null) {
      return;
    }
    await stoppedTask.kill();
    _passEvent(TaskKillEvent<T>(task));
  }

  @protected
  String safelyGetTaskIdFromTask(Task<T> task) => task.id;

  @protected
  String safelyExtractTaskIdFromString(String taskId) => taskId;

  AsyncTaskCompleterReference<T>? _stopAndReturnReference(
    AsynchronousTask<T> task,
  ) {
    final reference = _references[safelyGetTaskIdFromTask(task)];

    if (reference == null) {
      return null;
    }

    if (reference.isInternalCompleterCompleted) {
      return null;
    }

    _references.remove(safelyGetTaskIdFromTask(task));

    return reference..completeInternalCompleter();
  }

  AsyncTaskCompleterReference<T> _createReferenceOf(AsynchronousTask<T> task) {
    return _references[safelyGetTaskIdFromTask(task)] =
        AsyncTaskCompleterReference<T>.create(task);
  }

  bool _isReferenceOutDated(AsyncTaskCompleterReference<T> previous) {
    return previous.isInternalCompleterCompleted;
  }

  void _passEvent(TaskEvent<T> event) {
    if (!_onEventController.isClosed) {
      _onEventController.add(event);
      onEventCallback(event);
    }
  }

  void _changeState(T newState, Task<T> task) {
    mutateState(newState);
    _passEvent(TaskSuccessEvent<T>(task, _state));
  }

  void _onAsyncTaskSuccess(
    T potentialState,
    AsyncTaskCompleterReference<T> reference,
  ) {
    if (_isReferenceOutDated(reference)) {
      return;
    }
    _changeState(potentialState, reference.task);
    reference.completeInternalCompleter();
    _references.remove(safelyGetTaskIdFromTask(reference.task));
  }

  void _onAsyncTaskError(
    AsyncTaskCompleterReference<T> reference,
    dynamic error,
    StackTrace? trace,
  ) {
    if (_isReferenceOutDated(reference)) {
      return;
    }
    _passEvent(TaskErrorEvent<T>(reference.task, error, trace));
    reference.completeInternalCompleter();
    _references.remove(safelyGetTaskIdFromTask(reference.task));
  }

  Future<void> _handleAsyncTask(AsynchronousTask<T> task) async {
    final stoppedTask = _stopAndReturnReference(task)?.task;

    _passEvent(TaskLoadingEvent<T>(task));

    if (stoppedTask is CancelableAsyncTaskMixin<T>) {
      await stoppedTask.kill();
    }

    final newTaskReference = _createReferenceOf(task);

    unawaited(
      task.run().then(
            (value) => _onAsyncTaskSuccess(value, newTaskReference),
            onError: (error, stackTrace) =>
                _onAsyncTaskError(newTaskReference, error, stackTrace),
          ),
    );
  }

  void _handleSyncTask(SynchronousTask<T> task) {
    _changeState(task.run(), task);
  }
}
