import 'dart:collection';

import 'package:manager/src/models/manager.dart';
import 'package:manager/src/models/task_event.dart';
import 'package:meta/meta.dart';

mixin RecordTaskEventsMixin<T> on Manager<T> {
  final Map<String, TaskEvent<T>> _eventTable = {};

  TaskEvent<T>? getRecordedEvent({required String taskId}) =>
      _eventTable[safelyExtractTaskIdFromString(taskId)];

  @protected
  Map<String, TaskEvent<T>> get eventTable =>
      UnmodifiableMapView({..._eventTable});

  @mustCallSuper
  @protected
  void recordEvent(TaskEvent<T> event) {
    _eventTable[safelyGetTaskIdFromTask(event.task)] = event;
  }

  @mustCallSuper
  @protected
  void deleteRecordEvent({required String taskId}) {
    _eventTable.remove(safelyExtractTaskIdFromString(taskId));
  }

  @mustCallSuper
  @override
  Future<void> killById({required String taskId}) async {
    deleteRecordEvent(taskId: taskId);
    return super.killById(taskId: taskId);
  }

  @mustCallSuper
  @override
  void onEventCallback(TaskEvent<T> event) {
    recordEvent(event);
  }
}
