import 'dart:async';

abstract class Task<T> {
  FutureOr<T> run();

  String get id;

  const Task();
}

abstract class AsynchronousTask<T> extends Task<T> {
  @override
  Future<T> run();

  FutureOr<void> kill();

  bool get shouldKBeKilled;
  bool get waitForPreviousIdenticalTask;

  const AsynchronousTask();
}

abstract class SynchronousTask<T> extends Task<T> {
  @override
  T run();

  const SynchronousTask();
}
