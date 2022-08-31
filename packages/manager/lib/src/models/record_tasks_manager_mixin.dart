import 'package:manager/src/models/manager.dart';
import 'package:manager/src/models/task_event.dart';
import 'package:meta/meta.dart';

mixin RecordTaskEventsMixin<T> on Manager<T> {
  final Map<String, TaskEvent<T>> _eventTable = {};

  TaskEvent<T>? getRecordedEvent({required String taskId}) =>
      _eventTable[safelyExtractTaskIdFromString(taskId)];

  @mustCallSuper
  @override
  void onEventCallback(TaskEvent<T> event) {
    _eventTable[safelyGetTaskIdFromTask(event.task)] = event;
  }
}
