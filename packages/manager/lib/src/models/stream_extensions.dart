import 'package:manager/src/models/task_event.dart';
import 'package:manager/src/utils/stream_extensions.dart';

/// Special stream semantics on [Stream] of [TaskEvent]
extension TaskEventStreamExtension<T> on Stream<TaskEvent<T>> {
  /// Get a stream of [TaskLoadingEvent]s only
  Stream<TaskLoadingEvent<T>> loading() =>
      whereTypeFilter<TaskLoadingEvent<T>>();

  /// Get a stream of [TaskSuccessEvent]s only
  Stream<TaskSuccessEvent<T>> success() =>
      whereTypeFilter<TaskSuccessEvent<T>>();

  /// Get a stream of [TaskErrorEvent]s only
  Stream<TaskErrorEvent<T>> failed() => whereTypeFilter<TaskErrorEvent<T>>();

  /// Get a stream of [TaskKillEvent]s only
  Stream<TaskKillEvent<T>> killed() => whereTypeFilter<TaskKillEvent<T>>();
}
