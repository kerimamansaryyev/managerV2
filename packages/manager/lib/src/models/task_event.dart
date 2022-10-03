import 'package:manager/src/models/manager.dart';
import 'package:manager/src/models/task.dart';
import 'package:manager/src/models/task_mixins.dart';
import 'package:meta/meta.dart';

/// Semantics that are used to represent a progress of [Task].
enum TaskProgressStatus {
  /// If [Task] has not completed its [Task.run] yet and still tracked by [Manager].
  loading,

  /// If [Task] has completed its [Task.run] with an exception.
  error,

  /// If [Task] has completed its [Task.run] with success.
  success,

  /// If [Task] was killed by [Manager.killById] or [Manager.kill].
  killed,

  /// If [Task] does not exist in [Manager].
  none
}

extension TaskProgressStatusPublicGetExtension on TaskEvent? {
  /// If [TaskEvent] is null, it will return [TaskProgressStatus.none]. Otherwise, the method will return [TaskEvent.progressStatus].
  TaskProgressStatus get status =>
      this?.progressStatus ?? TaskProgressStatus.none;
}

/// A class that is used to represent a value emitted by [Manager.on]
@immutable
abstract class TaskEvent<T> {
  TaskProgressStatus get progressStatus;
  Task<T> get task;
}

/// A class that is used to represent a loading state of [AsynchronousTask]s in [Manager.on].
class TaskLoadingEvent<T> implements TaskEvent<T> {
  @override
  final Task<T> task;

  const TaskLoadingEvent(this.task);

  @override
  TaskProgressStatus get progressStatus => TaskProgressStatus.loading;
}

/// A class that is used to represent an error state of [AsynchronousTask]s in [Manager.on].
class TaskErrorEvent<T> implements TaskEvent<T> {
  final dynamic exception;
  final StackTrace? stackTrace;

  @override
  final Task<T> task;

  const TaskErrorEvent(this.task, this.exception, this.stackTrace);

  @override
  TaskProgressStatus get progressStatus => TaskProgressStatus.error;
}

/// A class that is used to represent a success state of [AsynchronousTask]s or [SynchronousTask]s in [Manager.on].
class TaskSuccessEvent<T> implements TaskEvent<T> {
  final T result;
  @override
  final Task<T> task;

  const TaskSuccessEvent(this.task, this.result);

  @override
  TaskProgressStatus get progressStatus => TaskProgressStatus.error;
}

/// A class that is used to represent a state when [CancelableAsyncTaskMixin]s are killed in [Manager.on].
class TaskKillEvent<T> implements TaskEvent<T> {
  @override
  final Task<T> task;

  const TaskKillEvent(this.task);

  @override
  TaskProgressStatus get progressStatus => TaskProgressStatus.killed;
}
