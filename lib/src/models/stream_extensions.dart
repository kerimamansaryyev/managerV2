import 'package:manager/src/models/task_event.dart';
import 'package:manager/src/utils/stream_extensions.dart';

extension TaskEventStreamExtension<T> on Stream<TaskEvent<T>> {
  Stream<TaskLoadingEvent<T>> loading() =>
      whereTypeFilter<TaskLoadingEvent<T>>();

  Stream<TaskSuccessEvent<T>> success() =>
      whereTypeFilter<TaskSuccessEvent<T>>();

  Stream<TaskErrorEvent<T>> failed() => whereTypeFilter<TaskErrorEvent<T>>();

  Stream<TaskKillEvent<T>> killed() => whereTypeFilter<TaskKillEvent<T>>();
}
