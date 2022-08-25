import 'dart:async';

import 'package:manager/src/models/task.dart';
import 'package:meta/meta.dart';

@immutable
class AsyncTaskCompleterReference<T> {
  final AsynchronousTask<T> task;

  @protected
  final Completer<void> completer;

  Future<void> get inernalCompleterFuture => completer.future;

  void completeInternalCompleter() => completer.complete();

  bool get isInternalCompleterCompleted => completer.isCompleted;

  const AsyncTaskCompleterReference._(
      {required this.completer, required this.task});

  AsyncTaskCompleterReference.create(AsynchronousTask<T> task)
      : this._(task: task, completer: Completer());
}
