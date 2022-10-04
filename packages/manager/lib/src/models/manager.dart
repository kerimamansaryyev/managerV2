import 'dart:async';
import 'dart:collection';

import 'package:async/async.dart';
import 'package:manager/src/models/async_task_references.dart';
import 'package:manager/src/models/task.dart';
import 'package:manager/src/models/task_event.dart';
import 'package:manager/src/models/task_mixins.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

class ManagerDisposedException implements Exception {
  const ManagerDisposedException();
}

typedef AsyncTaskCompleterReferenceTable<T>
    = Map<String, AsyncTaskCompleterReference<T>>;

/// An event-driven structure that has the single [state] of a type [T].
///
/// State changes are encapsulated and only possible to be changed internally by calling
/// [mutateState] or by running a [Task] via [run] method.
///
/// Key features and advantages:
/// - Every single attempt to change the [state] has its id and will be tracked.
/// - The manager allows running multiple [AsynchronousTask]s concurrently and track progress
/// progress of them through [on] method.
/// - It is possible to filter and listen to incoming [TaskEvent]s through [on] method by
/// a type of a [Task] or by [Task.id].
/// - If you run a [Task] and manager already has a task with the same id - the previous task will be dismissed.
/// So you don't need to worry about unwanted outcomes.
/// - An each [Task] that was completed with [TaskSuccessEvent] will change the state through [mutateState].
/// - You can track an every state change by listening to [onStateChanged]
abstract class Manager<T> {
  final Map<String, TaskEvent<T>> _eventSnapshotTable = {};
  final AsyncTaskCompleterReferenceTable<T> _references = {};
  final StreamController<T> _onStateChangedController =
      StreamController.broadcast();
  final StreamController<TaskEvent<T>> _onEventController =
      StreamController.broadcast();
  final BehaviorSubject<TaskEvent<T>> _onEventControllerWithLatestEvent =
      BehaviorSubject();
  late final BehaviorSubject<T> _onStateChangedControllerWithLatest;

  T _state;
  bool _isDisposed = false;

  Manager(T initialValue)
      : _state = initialValue,
        _onStateChangedControllerWithLatest =
            BehaviorSubject.seeded(initialValue);
  @protected
  Map<String, TaskEvent<T>> get eventSnapshotTable =>
      UnmodifiableMapView({..._eventSnapshotTable});

  /// If [dispose] was called on the manager
  bool get isDisposed => _isDisposed;

  /// Current state of the manager.
  T get state => _state;

  /// Emits an event each time [on] or [onStateChanged] fires an event.
  Stream<void> get onUpdated =>
      StreamGroup.mergeBroadcast([on(), onStateChanged()]).map((event) {
        return;
      });

  /// All events coming from [onEventCallback] are recorded in the [_eventSnapshotTable] map and can be accessed
  /// by this method using [taskId].
  TaskEvent<T>? getEventSnapshot({required String taskId}) =>
      _eventSnapshotTable[safelyExtractTaskIdFromString(taskId)];

  /// Emits an event each time the [state] is changed in [mutateState]
  ///
  /// If [withLatest] is `true`, the stream will emit the latest immidiately event to every
  /// subscriber that listens to it.
  Stream<T> onStateChanged({
    bool withLatest = false,
  }) =>
      _decideOnStateControllerStream(withLatest);

  /// Emits [TaskEvent] while tracking the [Task]s
  ///
  /// Emits an event if the condition is true:
  /// - `(taskId == null && S == Task<V>)` => both [taskId] and [S] are not provided
  ///
  /// or
  ///
  /// - `(taskId == task.id && S == Task<V>)` => [taskId] matches the condition and [S] is not provided
  ///
  /// or
  ///
  /// - `(taskId == task.id && task is S)` => both [taskId] and [S] match the bounds
  ///
  /// or
  ///
  /// - `(taskId == null && task is S)` => [taskId] is not provided and [S] matches the bounds.
  Stream<TaskEvent<T>> on<S extends Task<T>>({
    String? taskId,
    bool withLatest = false,
  }) =>
      _decideOnEventControllerStream(withLatest)
          .where((event) => tasFlexibleFilter<S, T>(event.task, taskId));

  /// Gives a reference for the [AsynchronousTask] tracked by the manager by [taskId].
  ///
  /// See also: [AsyncTaskCompleterReference]
  AsyncTaskCompleterReference<T>? getAsyncReferenceOf({
    required String taskId,
  }) =>
      _references[safelyExtractTaskIdFromString(taskId)];

  /// * If the manager runs a [SynchronousTask] - only [TaskSuccessEvent] will be added to the [on] stream.
  /// * If the manager runs an [AsynchronousTask] - the events will be added to the [on] stream depending on following cases:
  ///   - It add [TaskLoadingEvent] to the [on] stream before running [AsynchronousTask.run]. If the manager is already tracking
  ///   a task with the same [Task.id] and if the [task] is [CancelableAsyncTaskMixin] - a [task] will be killed before running. ([TaskKillEvent] `wont't` be emitted)
  ///   - If future [AsynchronousTask.run] of [task] completes without error - [TaskSuccessEvent] will be added to the [on] stream and [mutateState] will be called and the [state] gets mutated. (If the reference to this task is not outdated.)
  /// - If future [AsynchronousTask.run] of [task] completes with error - [TaskErrorEvent] will be added to the [on] stream. (If the reference to this task is not outdated.)
  @mustCallSuper
  void run(Task<T> task) {
    if (isDisposed) {
      throw const ManagerDisposedException();
    }
    if (task is AsynchronousTask<T>) {
      _handleAsyncTask(task);
    } else if (task is SynchronousTask<T>) {
      _handleSyncTask(task);
    }
  }

  /// Saves the [event] into [_eventSnapshotTable] map
  @mustCallSuper
  @protected
  void recordEventSnapshot(TaskEvent<T> event) {
    _eventSnapshotTable[safelyGetTaskIdFromTask(event.task)] = event;
  }

  /// Deletes an reference of the event of the [taskId] from the [_eventSnapshotTable] map
  @mustCallSuper
  @protected
  void deleteRecordEventSnapshot({required String taskId}) {
    _eventSnapshotTable.remove(safelyExtractTaskIdFromString(taskId));
  }

  /// The method kills a task found by [taskId] and [TaskKillEvent] will be added to the [on] stream.
  ///
  /// It `won't` have effect if:
  /// - If there are no references found for [taskId]. (Hadn't been run previously or already completed with either [TaskSuccessEvent] or [TaskErrorEvent])
  /// - The referenced task is not [CancelableAsyncTaskMixin].
  ///
  /// See also: [kill]
  @mustCallSuper
  Future<void> killById({required String taskId}) async {
    if (isDisposed) {
      throw const ManagerDisposedException();
    }
    final reference = _references[safelyExtractTaskIdFromString(taskId)];
    final task = reference?.task;
    if (task is! CancelableAsyncTaskMixin<T>) {
      return;
    }
    deleteRecordEventSnapshot(taskId: taskId);
    return kill(task);
  }

  /// Closing all the sinks of manager.
  ///
  /// `Warning`: if
  @mustCallSuper
  void dispose() {
    if (isDisposed) {
      throw const ManagerDisposedException();
    }
    _isDisposed = true;
    _onStateChangedController.close();
    _onStateChangedControllerWithLatest.close();
    _onEventController.close();
    _onEventControllerWithLatestEvent.close();
  }

  @visibleForTesting
  String testAsyncTaskIdPivotGeneratorRaw(String taskId) =>
      safelyExtractTaskIdFromString(taskId);

  @visibleForTesting
  Future<void> waitForTaskToBeDone({required String taskId}) =>
      getAsyncReferenceOf(taskId: taskId)?.internalCompleterFuture ??
      Future.value(null);

  /// This method changes the [_state] and adds events to [onStateChanged]
  @mustCallSuper
  @protected
  void mutateState(T newState) {
    _state = newState;
    if (!isDisposed) {
      _onStateChangedController.add(_state);
      _onStateChangedControllerWithLatest.add(state);
    }
  }

  @mustCallSuper
  @protected
  void onEventCallback(TaskEvent<T> event) {
    recordEventSnapshot(event);
  }

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

  /// Encapsulated method to form the id of [Task] to get a reference properly
  @protected
  String safelyGetTaskIdFromTask(Task<T> task) => task.id;

  /// Encapsulated method to form the [taskId] to get a reference of tasks properly
  @protected
  String safelyExtractTaskIdFromString(String taskId) => taskId;

  Stream<TaskEvent<T>> _decideOnEventControllerStream(bool withLatestEvent) {
    if (withLatestEvent) {
      return _onEventControllerWithLatestEvent.stream;
    } else {
      return _onEventController.stream;
    }
  }

  Stream<T> _decideOnStateControllerStream(bool withLatestEvent) {
    if (withLatestEvent) {
      return _onStateChangedControllerWithLatest.stream;
    } else {
      return _onStateChangedController.stream;
    }
  }

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
    if (!isDisposed) {
      onEventCallback(event);
      _onEventController.add(event);
      _onEventControllerWithLatestEvent.add(event);
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
    if (_isReferenceOutDated(reference) || isDisposed) {
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
    if (_isReferenceOutDated(reference) || isDisposed) {
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

    if (isDisposed) {
      return;
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

  /// Description:
  ///
  /// - `(taskId == null && S == Task<V>)` => both [taskId] and [S] are not provided
  ///
  /// or
  ///
  /// - `(taskId == task.id && S == Task<V>)` => [taskId] matches the condition and [S] is not provided
  ///
  /// or
  ///
  /// - `(taskId == task.id && task is S)` => both [taskId] and [S] match the bounds
  ///
  /// or
  ///
  /// - `(taskId == null && task is S)` => [taskId] is not provided and [S] matches the bounds
  @internal
  static bool tasFlexibleFilter<S extends Task<V>, V>(
    Task task,
    String? taskId,
  ) =>
      (taskId == null && S == Task<V>) ||
      (taskId == task.id && S == Task<V>) ||
      (taskId == task.id && task is S) ||
      (taskId == null && task is S);
}
