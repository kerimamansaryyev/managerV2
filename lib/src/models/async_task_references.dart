import 'dart:async';

import 'package:manager/src/models/task.dart';
import 'package:meta/meta.dart';

class AsyncTimestampSnapshot {
  DateTime? _timeStamp;

  DateTime? get timeStamp => _timeStamp;

  void checkout() {
    _timeStamp = DateTime.now();
  }
}

@immutable
class AsyncTaskCompleterReference<T> {
  final AsynchronousTask<T> task;
  final Completer<T> completer;
  final AsyncTimestampSnapshot timestampSnapshot;

  const AsyncTaskCompleterReference._(
      {required this.completer,
      required this.task,
      required this.timestampSnapshot});

  AsyncTaskCompleterReference.create(AsynchronousTask<T> task)
      : this._(
            task: task,
            completer: Completer(),
            timestampSnapshot: AsyncTimestampSnapshot());
}
