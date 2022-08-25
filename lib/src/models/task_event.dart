import 'package:manager/src/models/task.dart';
import 'package:meta/meta.dart';

enum TaskProgressStatus { loading, error, success }

@immutable
abstract class TaskEvent<T> {
  TaskProgressStatus get status;
  Task<T> get task;
}

class TaskLoadingEvent<T> implements TaskEvent<T> {
  TaskLoadingEvent(this.task);

  @override
  final Task<T> task;

  @override
  TaskProgressStatus get status => TaskProgressStatus.loading;
}

class TaskErrorEvent<T> implements TaskEvent<T> {
  @override
  TaskProgressStatus get status => TaskProgressStatus.error;

  @override
  final Task<T> task;

  final dynamic exception;
  final StackTrace? stackTrace;

  TaskErrorEvent(this.task, this.exception, this.stackTrace);
}

class TaskSuccessEvent<T> implements TaskEvent<T> {
  @override
  TaskProgressStatus get status => TaskProgressStatus.error;

  @override
  final Task<T> task;

  final T result;

  TaskSuccessEvent(this.task, this.result);
}
