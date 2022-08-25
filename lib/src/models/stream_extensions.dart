import 'package:manager/src/models/task_event.dart';

extension TaskEventStreamExtension<T> on Stream<TaskEvent<T>> {
  Stream<TaskEvent<T>> loading() =>
      where((event) => event is TaskLoadingEvent<T>);

  Stream<TaskEvent<T>> success() =>
      where((event) => event is TaskSuccessEvent<T>);

  Stream<TaskEvent<T>> error() => where((event) => event is TaskErrorEvent<T>);
}
