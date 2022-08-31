import 'package:manager/src/models/task.dart';
import 'package:meta/meta.dart';

enum TaskProgressStatus { loading, error, success, killed }

@immutable
abstract class TaskEvent<T> {
  TaskProgressStatus get status;
  Task<T> get task;
}

class TaskLoadingEvent<T> implements TaskEvent<T> {
  @override
  final Task<T> task;

  @override
  TaskProgressStatus get status => TaskProgressStatus.loading;

  const TaskLoadingEvent(this.task);
}

class TaskErrorEvent<T> implements TaskEvent<T> {
  @override
  TaskProgressStatus get status => TaskProgressStatus.error;

  @override
  final Task<T> task;

  final dynamic exception;
  final StackTrace? stackTrace;

  const TaskErrorEvent(this.task, this.exception, this.stackTrace);
}

class TaskSuccessEvent<T> implements TaskEvent<T> {
  @override
  TaskProgressStatus get status => TaskProgressStatus.error;

  @override
  final Task<T> task;

  final T result;

  const TaskSuccessEvent(this.task, this.result);
}

class TaskKillEvent<T> implements TaskEvent<T> {
  @override
  TaskProgressStatus get status => TaskProgressStatus.killed;

  @override
  final Task<T> task;

  const TaskKillEvent(this.task);
}
