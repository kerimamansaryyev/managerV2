import 'dart:async';

import 'package:manager/src/models/async_task_references.dart';
import 'package:manager/src/models/task.dart';
import 'package:manager/src/models/task_event.dart';

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
  Stream<TaskEvent<T>> on<S extends Task>() =>
      _onEventController.stream.where((event) => event.task is S);

  AsyncTaskCompleterReference<T>? _stopAndReturnReference(
      AsynchronousTask<T> task) {
    final reference = _references[task.id];
    if (reference == null) return null;

    if (reference.completer.isCompleted) {
      return null;
    }

    _references.remove(task.id);

    return reference
      ..cyclestampSnapshot.checkout()
      ..completer.complete();
  }

  AsyncTaskCompleterReference<T> _createReferenceOf(AsynchronousTask<T> task) {
    return _references[task.id] = AsyncTaskCompleterReference<T>.create(task)
      ..cyclestampSnapshot.checkout();
  }

  AsyncTaskCompleterReference<T>? _getReferenceFromTask(
          AsynchronousTask<T> task) =>
      _references[task.id];

  void _changeState(T newState, Task<T> task) {
    _state = newState;
    _onEventController.add(TaskSuccessEvent<T>(task, _state));
  }

  void _onAsyncTaskSuccess(
      T potentialState, AsyncTaskCompleterReference<T> referenceBeforeTask) {
    final freshReference = _getReferenceFromTask(referenceBeforeTask.task);
    if (freshReference == null ||
        referenceBeforeTask.completer.isCompleted ||
        referenceBeforeTask.isOutDatedComparingTo(freshReference)) {
      return;
    }
    _changeState(potentialState, freshReference.task);
    freshReference.completer.complete();
  }

  void _onAsyncTaskError(AsyncTaskCompleterReference<T> referenceBeforeTask,
      dynamic error, StackTrace? trace) {
    final freshReference = _getReferenceFromTask(referenceBeforeTask.task);
    if (freshReference == null ||
        referenceBeforeTask.completer.isCompleted ||
        referenceBeforeTask.isOutDatedComparingTo(freshReference)) {
      return;
    }

    _onEventController
        .add(TaskErrorEvent<T>(freshReference.task, error, trace));
    freshReference.completer.complete();
  }

  Future<void> _handleAsyncTask(AsynchronousTask<T> task) async {
    final reference = _getReferenceFromTask(task);
    if (reference != null &&
        reference.task.waitForPreviousIdenticalTask &&
        !reference.completer.isCompleted) {
      return;
    }

    final stoppedTaskReference = _stopAndReturnReference(task)?.task;

    _onEventController.add(TaskLoadingEvent<T>(task));

    if (stoppedTaskReference != null && stoppedTaskReference.shouldKBeKilled) {
      await stoppedTaskReference.kill();
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

  Future<void> kill(AsynchronousTask<T> task) async {
    _stopAndReturnReference(task);
    await task.kill();
    _onEventController.add(TaskKillEvent<T>(task));
  }

  void dispose() {
    _onStateChangedController.close();
  }
}
