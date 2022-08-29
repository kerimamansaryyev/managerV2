import 'dart:async';

import 'package:meta/meta.dart';

@immutable
abstract class Task<T> {
  String get id;

  FutureOr<T> run();

  const Task();
}

@immutable
abstract class AsynchronousTask<T> implements Task<T> {
  @override
  Future<T> run();

  const AsynchronousTask();
}

@immutable
abstract class SynchronousTask<T> implements Task<T> {
  @override
  T run();

  const SynchronousTask();
}

class GenericSyncTask<T> extends SynchronousTask<T> {
  final T Function() _runFunction;

  @override
  final String id;

  @override
  T run() => _runFunction();

  const GenericSyncTask(
      {required this.id, required T Function() resultFunction})
      : _runFunction = resultFunction;
}

class GenericAsyncTask<T> extends AsynchronousTask<T> {
  @protected
  final Future<T> Function() computation;

  @override
  final String id;

  @override
  Future<T> run() => computation();

  const GenericAsyncTask({required this.id, required this.computation});
}
