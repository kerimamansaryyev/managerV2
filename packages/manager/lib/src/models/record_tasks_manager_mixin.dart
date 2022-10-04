import 'dart:collection';

import 'package:manager/src/models/manager.dart';
import 'package:manager/src/models/task_event.dart';
import 'package:meta/meta.dart';

/// A special type of [Manager] that records events of [onEventCallback] and allows
/// accessing them through [getRecordedEvent]
@Deprecated(
  'Starting from 0.4.0, Manager class supports the following methods of the mixin be default',
)
mixin RecordTaskEventsMixin<T> on Manager<T> {
  final Map<String, TaskEvent<T>> _eventTable = {};

  /// All events coming from [onEventCallback] are recorded in the [_eventTable] map and can be accessed
  /// by this method using [taskId].
  TaskEvent<T>? getRecordedEvent({required String taskId}) =>
      _eventTable[safelyExtractTaskIdFromString(taskId)];

  @protected
  Map<String, TaskEvent<T>> get eventTable =>
      UnmodifiableMapView({..._eventTable});

  /// Saves the [event] into [_eventTable] map
  @mustCallSuper
  @protected
  void recordEvent(TaskEvent<T> event) {
    _eventTable[safelyGetTaskIdFromTask(event.task)] = event;
  }

  /// Deletes an reference of the event of the [taskId] from the [_eventTable] map
  @mustCallSuper
  @protected
  void deleteRecordEvent({required String taskId}) {
    _eventTable.remove(safelyExtractTaskIdFromString(taskId));
  }

  /// Deletes a reference of the event of the [taskId] from the [_eventTable] map before the task of [taskId] is killed
  @mustCallSuper
  @override
  Future<void> killById({required String taskId}) async {
    deleteRecordEvent(taskId: taskId);
    return super.killById(taskId: taskId);
  }

  /// Records the [event] into the [_eventTable]
  @mustCallSuper
  @override
  void onEventCallback(TaskEvent<T> event) {
    recordEvent(event);
    super.onEventCallback(event);
  }
}
