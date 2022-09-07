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

  const TaskLoadingEvent(this.task);

  @override
  TaskProgressStatus get status => TaskProgressStatus.loading;
}

class TaskErrorEvent<T> implements TaskEvent<T> {
  final dynamic exception;
  final StackTrace? stackTrace;

  @override
  final Task<T> task;

  const TaskErrorEvent(this.task, this.exception, this.stackTrace);

  @override
  TaskProgressStatus get status => TaskProgressStatus.error;
}

class TaskSuccessEvent<T> implements TaskEvent<T> {
  final T result;
  @override
  final Task<T> task;

  const TaskSuccessEvent(this.task, this.result);

  @override
  TaskProgressStatus get status => TaskProgressStatus.error;
}

class TaskKillEvent<T> implements TaskEvent<T> {
  @override
  final Task<T> task;

  const TaskKillEvent(this.task);

  @override
  TaskProgressStatus get status => TaskProgressStatus.killed;
}
