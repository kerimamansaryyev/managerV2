import 'dart:async';

import 'package:manager/src/models/async_task_references.dart';
import 'package:manager/src/models/task.dart';
import 'package:manager/src/models/task_event.dart';

typedef AsyncTaskCompleterReferenceTable<T>
    = Map<String, AsyncTaskCompleterReference<T>>;

abstract class Manager<T> {
  final AsyncTaskCompleterReferenceTable<T> _completers = {};
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

  AsyncTaskCompleterReference<T>? _assureCompleterIsCompleted(
      AsynchronousTask<T> task) {
    final reference = _completers[task.id];
    if (reference == null) return null;

    if (reference.completer.isCompleted) {
      return null;
    }

    _completers.remove(task.id);

    return reference
      ..timestampSnapshot.checkout()
      ..completer.complete();
  }

  void _createReferenceOf(AsynchronousTask<T> task) {
    _completers[task.id] = AsyncTaskCompleterReference.create(task);
  }

  void _changeState(T newState) {
    _state = newState;
  }

  Future<void> _handleAsyncTask(AsynchronousTask<T> task) async {
    final previousReferencedTask = _assureCompleterIsCompleted(task)?.task;
    _createReferenceOf(task);

    _onEventController.add(TaskLoadingEvent<T>(task));

    if (previousReferencedTask != null) {
      await previousReferencedTask.kill();
    }
  }

  void _handleSyncTask(SynchronousTask<T> task) {
    _changeState((task).run());
  }

  void run(Task<T> task) {
    if (task is AsynchronousTask<T>) {
      _handleAsyncTask(task);
    } else if (task is SynchronousTask<T>) {
      _handleSyncTask(task);
    }
  }

  void dispose() {
    _onStateChangedController.close();
  }
}
