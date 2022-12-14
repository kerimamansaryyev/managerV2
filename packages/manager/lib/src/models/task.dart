import 'dart:async';

import 'package:manager/src/models/manager.dart';
import 'package:meta/meta.dart';

/// A structure that represents a mutation operation
/// applied to [Manager.run].
///
/// [id] is used to distinguish one task from another while being tracked by [Manager].
@immutable
abstract class Task<T> {
  const Task();

  /// Used to distinguish one task from another while being tracked by [Manager].
  String get id;

  FutureOr<T> run();
}

@immutable
abstract class AsynchronousTask<T> implements Task<T> {
  const AsynchronousTask();

  const factory AsynchronousTask.generic({
    required String id,
    required Future<T> Function() computation,
  }) = GenericAsyncTask;
  @override
  Future<T> run();
}

@immutable
abstract class SynchronousTask<T> implements Task<T> {
  const SynchronousTask();

  const factory SynchronousTask.generic({
    required String id,
    required T result,
  }) = GenericSyncTask;

  @override
  T run();
}

class GenericSyncTask<T> extends SynchronousTask<T> {
  final T result;

  @override
  final String id;

  const GenericSyncTask({required this.id, required this.result});

  @override
  T run() => result;
}

class GenericAsyncTask<T> extends AsynchronousTask<T> {
  @protected
  final Future<T> Function() computation;

  @override
  final String id;

  const GenericAsyncTask({required this.id, required this.computation});

  @override
  Future<T> run() => computation();
}
