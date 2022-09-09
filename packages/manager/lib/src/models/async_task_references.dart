import 'dart:async';

import 'package:manager/src/models/manager.dart';
import 'package:manager/src/models/task.dart';
import 'package:meta/meta.dart';

/// A class that represents a references saved and tracked by [Manager]
@immutable
class AsyncTaskCompleterReference<T> {
  @protected
  final Completer<void> completer;
  final AsynchronousTask<T> task;

  const AsyncTaskCompleterReference._({
    required this.completer,
    required this.task,
  });

  AsyncTaskCompleterReference.create(AsynchronousTask<T> task)
      : this._(task: task, completer: Completer());

  bool get isCompleted => isInternalCompleterCompleted;
  Future<void> get future => internalCompleterFuture;
  @internal
  Future<void> get internalCompleterFuture => completer.future;
  @internal
  bool get isInternalCompleterCompleted => completer.isCompleted;

  @internal
  void completeInternalCompleter() => completer.complete();
}
