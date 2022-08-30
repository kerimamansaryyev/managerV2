import 'dart:async';

import 'package:manager/src/models/task.dart';
import 'package:meta/meta.dart';

@immutable
class AsyncTaskCompleterReference<T> {
  final AsynchronousTask<T> task;

  @protected
  final Completer<void> completer;

  @internal
  Future<void> get internalCompleterFuture => completer.future;

  @internal
  bool get isInternalCompleterCompleted => completer.isCompleted;

  @internal
  void completeInternalCompleter() => completer.complete();

  bool get isCompleted => isInternalCompleterCompleted;

  Future<void> get future => internalCompleterFuture;

  const AsyncTaskCompleterReference._(
      {required this.completer, required this.task});

  AsyncTaskCompleterReference.create(AsynchronousTask<T> task)
      : this._(task: task, completer: Completer());
}
