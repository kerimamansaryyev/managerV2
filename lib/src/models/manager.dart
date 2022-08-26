import 'dart:async';

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
  String _taskIdPivot(Task<T> task) => '${task.runtimeType}_${task.id}';
  String _taskIdPivotRaw<S extends Task<T>>(String? taskId) => '${S}_$taskId';
  Stream<T> get onStateChanged => _onStateChangedController.stream;
  Stream<TaskEvent<T>> on<S extends Task<T>>({String? taskId}) =>
      _onEventController.stream.where((event) =>
          (taskId == event.task.id && event is S) ||
          (event is S && taskId == null));

  AsyncTaskCompleterReference<T>? _stopAndReturnReference(
      AsynchronousTask<T> task) {
    final reference = _references[_taskIdPivot(task)];

    if (reference == null) return null;

    if (reference.isInternalCompleterCompleted) {
      return null;
    }

    _references.remove(_taskIdPivot(task));

    return reference..completeInternalCompleter();
  }

  AsyncTaskCompleterReference<T> _createReferenceOf(AsynchronousTask<T> task) {
    return _references[_taskIdPivot(task)] =
        AsyncTaskCompleterReference<T>.create(task);
  }

  AsyncTaskCompleterReference<T>? getReference<S extends Task<T>>(
          {String? taskId}) =>
      _references[_taskIdPivotRaw<S>(taskId)];

  bool _isReferenceOutDated(AsyncTaskCompleterReference<T> previous) {
    return previous.isInternalCompleterCompleted;
  }

  @visibleForTesting
  Future<void> waitForTaskToBeDone<S extends Task<T>>({String? taskId}) =>
      getReference<S>(taskId: taskId)?.inernalCompleterFuture ??
      Future.value(null);

  void _changeState(T newState, Task<T> task) {
    _state = newState;
    _onEventController.add(TaskSuccessEvent<T>(task, _state));
    _onStateChangedController.add(_state);
  }

  void _onAsyncTaskSuccess(
      T potentialState, AsyncTaskCompleterReference<T> reference) {
    if (_isReferenceOutDated(reference)) {
      return;
    }
    _changeState(potentialState, reference.task);
    reference.completeInternalCompleter();
    _references.remove(_taskIdPivot(reference.task));
  }

  void _onAsyncTaskError(AsyncTaskCompleterReference<T> reference,
      dynamic error, StackTrace? trace) {
    if (_isReferenceOutDated(reference)) {
      return;
    }
    _onEventController.add(TaskErrorEvent<T>(reference.task, error, trace));
    reference.completeInternalCompleter();
    _references.remove(_taskIdPivot(reference.task));
  }

  Future<void> _handleAsyncTask(AsynchronousTask<T> task) async {
    final stoppedTask = _stopAndReturnReference(task)?.task;

    _onEventController.add(TaskLoadingEvent<T>(task));

    if (stoppedTask is CancelableAsyncTaskMixin<T> &&
        stoppedTask.shouldBeKilled) {
      await stoppedTask.kill();
    }

    final newTaskReference = _createReferenceOf(task);

    task.run().then((value) => _onAsyncTaskSuccess(value, newTaskReference),
        onError: (error, stackTrace) =>
            _onAsyncTaskError(newTaskReference, error, stackTrace));
  }

  void _handleSyncTask(SynchronousTask<T> task) {
    _changeState((task).run(), task);
  }

  void run(Task<T> task) {
    if (task is AsynchronousTask<T>) {
      _handleAsyncTask(task);
    } else if (task is SynchronousTask<T>) {
      _handleSyncTask(task);
    }
  }

  Future<void> kill(CancelableAsyncTaskMixin<T> task) async {
    _stopAndReturnReference(task);
    await task.kill();
    _onEventController.add(TaskKillEvent<T>(task));
  }

  void dispose() {
    _onStateChangedController.close();
  }
}
