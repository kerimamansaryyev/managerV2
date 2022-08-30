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

  const factory AsynchronousTask.generic(
      {required String id,
      required Future<T> Function() computation}) = GenericAsyncTask;
}

@immutable
abstract class SynchronousTask<T> implements Task<T> {
  @override
  T run();

  const SynchronousTask();

  const factory SynchronousTask.generic(
      {required String id, required T result}) = GenericSyncTask;
}

class GenericSyncTask<T> extends SynchronousTask<T> {
  final T result;

  @override
  final String id;

  @override
  T run() => result;

  const GenericSyncTask({required this.id, required this.result});
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
